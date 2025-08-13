// services/subscription_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../models/subscription_data.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Product IDs
  static const String monthlyProductId = 'ai_vision_pro_monthly';
  static const String yearlyProductId = 'ai_vision_pro_yearly';
  static const String lifetimeProductId = 'ai_vision_pro_lifetime';

  /// Check if user has active subscription
  Future<bool> hasActiveSubscription() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check Firestore first
      final firestoreStatus = await _checkFirestoreSubscription(user.uid);
      if (firestoreStatus != null) {
        await _cacheSubscriptionStatus(firestoreStatus);
        return firestoreStatus.isActive;
      }

      // Fallback to local cache
      return await _getCachedSubscriptionStatus();
    } catch (e) {
      debugPrint('Error checking subscription: $e');
      return await _getCachedSubscriptionStatus();
    }
  }

  /// Save subscription to Firestore and local cache
  Future<void> saveSubscription({
    required String productId,
    required String transactionId,
    required DateTime purchaseDate,
    DateTime? expiryDate,
    required PurchaseDetails purchaseDetails,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final subscriptionData = SubscriptionData(
        userId: user.uid,
        productId: productId,
        transactionId: transactionId,
        purchaseDate: purchaseDate,
        expiryDate: expiryDate,
        isActive: true,
        platform: Platform.isIOS ? 'ios' : 'android',
        originalTransactionId: purchaseDetails.purchaseID,
        verificationData: purchaseDetails.verificationData.source,
      );

      // Save to Firestore
      await _firestore
          .collection('subscriptions')
          .doc(user.uid)
          .set(subscriptionData.toMap(), SetOptions(merge: true));

      // Cache locally
      await _cacheSubscriptionStatus(subscriptionData);

      debugPrint('✅ Subscription saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving subscription: $e');
      throw Exception('Failed to save subscription: $e');
    }
  }

  /// Validate subscription with platform stores
  Future<bool> validateSubscription() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Get current subscription
      final subscription = await _checkFirestoreSubscription(user.uid);
      if (subscription == null) return false;

      // For lifetime purchases, no validation needed
      if (subscription.productId == lifetimeProductId) {
        return subscription.isActive;
      }

      // Check if subscription expired
      if (subscription.expiryDate != null) {
        final now = DateTime.now();
        if (now.isAfter(subscription.expiryDate!)) {
          await _deactivateSubscription(user.uid);
          return false;
        }
      }

      // Validate with platform store
      if (Platform.isIOS) {
        return await _validateIOSSubscription(subscription);
      } else {
        return await _validateAndroidSubscription(subscription);
      }
    } catch (e) {
      debugPrint('Error validating subscription: $e');
      return false;
    }
  }

  /// Restore purchases
  Future<List<SubscriptionData>> restorePurchases() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await InAppPurchase.instance.restorePurchases();

      // Get restored purchases from Firestore
      final doc =
          await _firestore.collection('subscriptions').doc(user.uid).get();

      if (doc.exists) {
        final subscription = SubscriptionData.fromMap(doc.data()!);
        if (await validateSubscription()) {
          return [subscription];
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return [];
    }
  }

  /// Cancel subscription
  Future<void> cancelSubscription() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _deactivateSubscription(user.uid);
      await _clearCachedSubscription();

      debugPrint('✅ Subscription cancelled');
    } catch (e) {
      debugPrint('❌ Error cancelling subscription: $e');
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  /// Get subscription details
  Future<SubscriptionData?> getSubscriptionDetails() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      return await _checkFirestoreSubscription(user.uid);
    } catch (e) {
      debugPrint('Error getting subscription details: $e');
      return null;
    }
  }

  // Private methods

  Future<SubscriptionData?> _checkFirestoreSubscription(String userId) async {
    try {
      final doc =
          await _firestore.collection('subscriptions').doc(userId).get();

      if (doc.exists && doc.data() != null) {
        return SubscriptionData.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error checking Firestore subscription: $e');
      return null;
    }
  }

  Future<void> _deactivateSubscription(String userId) async {
    await _firestore.collection('subscriptions').doc(userId).update(
        {'isActive': false, 'cancelledAt': FieldValue.serverTimestamp()});
  }

  Future<bool> _validateIOSSubscription(SubscriptionData subscription) async {
    // Implement iOS receipt validation with Apple's servers
    // This is a simplified version - you should implement proper receipt validation
    try {
      // For now, check expiry date
      if (subscription.expiryDate != null) {
        return DateTime.now().isBefore(subscription.expiryDate!);
      }
      return subscription.isActive;
    } catch (e) {
      debugPrint('iOS validation error: $e');
      return false;
    }
  }

  Future<bool> _validateAndroidSubscription(
      SubscriptionData subscription) async {
    // Implement Google Play validation with Play Console API
    // This is a simplified version - you should implement proper validation
    try {
      // For now, check expiry date
      if (subscription.expiryDate != null) {
        return DateTime.now().isBefore(subscription.expiryDate!);
      }
      return subscription.isActive;
    } catch (e) {
      debugPrint('Android validation error: $e');
      return false;
    }
  }

  Future<void> _cacheSubscriptionStatus(SubscriptionData subscription) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', subscription.isActive);
    await prefs.setString('plan_type', subscription.productId);

    if (subscription.expiryDate != null) {
      await prefs.setString(
          'expiry_date', subscription.expiryDate!.toIso8601String());
    }

    await prefs.setString(
        'purchase_date', subscription.purchaseDate.toIso8601String());
  }

  Future<bool> _getCachedSubscriptionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isPremium = prefs.getBool('is_premium') ?? false;

      if (!isPremium) return false;

      // Check if cached subscription is expired
      final expiryDateString = prefs.getString('expiry_date');
      if (expiryDateString != null) {
        final expiryDate = DateTime.parse(expiryDateString);
        if (DateTime.now().isAfter(expiryDate)) {
          await _clearCachedSubscription();
          return false;
        }
      }

      return isPremium;
    } catch (e) {
      debugPrint('Error getting cached subscription: $e');
      return false;
    }
  }

  Future<void> _clearCachedSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_premium');
    await prefs.remove('plan_type');
    await prefs.remove('expiry_date');
    await prefs.remove('purchase_date');
  }
}
