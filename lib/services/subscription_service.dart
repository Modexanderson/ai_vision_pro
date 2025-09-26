import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../constants/ad_unit_ids.dart';
import '../models/subscription_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final InAppPurchase _iap = InAppPurchase.instance;

  // Product IDs
  static const String monthlyProductId = 'ai_vision_pro_monthly';
  static const String yearlyProductId = 'ai_vision_pro_yearly';
  static const String _cacheKey = 'subscription_cache';
  static const String _cacheIntegrityKey = 'subscription_cache_integrity';

  // Firebase Functions base URL (non-const to allow dotenv access)
  static String get _functionsBaseUrl =>
      'https://us-central1-${dotenv.env['FIREBASE_PROJECT_ID'] ?? 'aivisionpro'}.cloudfunctions.net';

  /// Check if user has active subscription
  Future<bool> hasActiveSubscription() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check Firestore first
      final subscriptionDoc =
          await _firestore.collection('subscriptions').doc(user.uid).get();
      if (subscriptionDoc.exists) {
        final data = subscriptionDoc.data()!;
        final isActive = data['isActive'] as bool;
        final expiryDate = (data['expiryDate'] as Timestamp?)?.toDate();
        final gracePeriodUntil = data['gracePeriodUntil'] != null
            ? DateTime.parse(data['gracePeriodUntil'] as String)
            : null;

        // Check grace period for offline
        if (gracePeriodUntil != null &&
            gracePeriodUntil.isAfter(DateTime.now())) {
          await _cacheSubscriptionStatus(SubscriptionData.fromMap(data));
          return true;
        }

        if (expiryDate != null && expiryDate.isBefore(DateTime.now())) {
          await _firestore
              .collection('subscriptions')
              .doc(user.uid)
              .update({'isActive': false});
          await _clearCachedSubscription();
          return false;
        }
        if (isActive) {
          final isValid = await _validateSubscription(user.uid);
          await _cacheSubscriptionStatus(SubscriptionData.fromMap(data));
          return isValid;
        }
      }

      // Fallback to cache with integrity check
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

      final platform = Platform.isIOS ? 'ios' : 'android';
      final purchaseData = {
        'receipt': platform == 'ios'
            ? purchaseDetails.verificationData.serverVerificationData
            : null,
        'purchaseToken': platform == 'android'
            ? purchaseDetails.verificationData.serverVerificationData
            : null,
      };

      // Call Firebase Function to process subscription
      final response = await http.post(
        Uri.parse('$_functionsBaseUrl/process_subscription'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': user.uid,
          'platform': platform,
          'purchaseData': purchaseData,
          'productId': productId,
        }),
      );

      if (response.statusCode != 200 || !jsonDecode(response.body)['success']) {
        throw Exception('Server failed to process subscription');
      }

      final subscriptionData = SubscriptionData(
        userId: user.uid,
        productId: productId,
        transactionId: transactionId,
        purchaseDate: purchaseDate,
        expiryDate: expiryDate,
        isActive: true,
        platform: platform,
        originalTransactionId: purchaseDetails.purchaseID,
        verificationData: purchaseDetails.verificationData.source,
        gracePeriodUntil: DateTime.now().add(const Duration(days: 7)),
      );

      // Save to Firestore
      await _firestore
          .collection('subscriptions')
          .doc(user.uid)
          .set(subscriptionData.toMap(), SetOptions(merge: true));

      // Cache locally with integrity
      await _cacheSubscriptionStatus(subscriptionData);

      debugPrint('✅ Subscription saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving subscription: $e');
      throw Exception('Failed to save subscription: $e');
    }
  }

  /// Validate subscription with platform stores
  Future<bool> _validateSubscription(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_functionsBaseUrl/validate_subscription'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['success'] && result['isValid'];
      }
      return false;
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

      await _iap.restorePurchases();

      // Get all subscriptions for user
      final subscriptionDocs = await _firestore
          .collection('subscriptions')
          .where('userId', isEqualTo: user.uid)
          .where('isActive', isEqualTo: true)
          .get();

      if (subscriptionDocs.docs.isNotEmpty) {
        // Select the latest subscription
        final latestSubscription = subscriptionDocs.docs.reduce((a, b) {
          final aDate = (a.data()['purchaseDate'] as Timestamp).toDate();
          final bDate = (b.data()['purchaseDate'] as Timestamp).toDate();
          return aDate.isAfter(bDate) ? a : b;
        });

        final subscriptionData =
            SubscriptionData.fromMap(latestSubscription.data());
        if (await _validateSubscription(user.uid)) {
          await _cacheSubscriptionStatus(subscriptionData);
          return [subscriptionData];
        }
      }

      await _clearCachedSubscription();
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

      final response = await http.post(
        Uri.parse('$_functionsBaseUrl/cancel_subscription'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': user.uid}),
      );

      if (response.statusCode != 200 || !jsonDecode(response.body)['success']) {
        throw Exception('Failed to cancel subscription');
      }

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

      final doc =
          await _firestore.collection('subscriptions').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return SubscriptionData.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting subscription details: $e');
      return null;
    }
  }

  /// Check API usage limits
  Future<bool> checkUsageLimits({int apiCalls = 1, int batchScans = 0}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final response = await http.post(
        Uri.parse('$_functionsBaseUrl/update_usage_limits'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': user.uid,
          'apiCalls': apiCalls,
          'batchScans': batchScans,
        }),
      );

      return response.statusCode == 200 && jsonDecode(response.body)['success'];
    } catch (e) {
      debugPrint('Error checking usage limits: $e');
      return false;
    }
  }

  /// Get available subscription plans
  Future<List<ProductDetails>> getAvailablePlans() async {
    final productIds = AdUnitIds.allProductIds;
    final response = await _iap.queryProductDetails(productIds);
    return response.productDetails.map((product) {
      String description = '';
      if (product.id.contains('monthly')) {
        description =
            'Unlock all premium features: Real-time detection, advanced analytics, API access, ad-free experience, priority support. \$9.99/month.';
      } else if (product.id.contains('yearly')) {
        description =
            'All Monthly features + early access to new AI models. Save 33%! \$79.99/year.';
      }
      return ProductDetails(
        id: product.id,
        title: product.title,
        description: description,
        price: product.price,
        rawPrice: product.rawPrice,
        currencyCode: product.currencyCode,
      );
    }).toList();
  }

  // Private methods

  Future<void> _cacheSubscriptionStatus(SubscriptionData subscription) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = {
      'userId': subscription.userId,
      'productId': subscription.productId,
      'transactionId': subscription.transactionId,
      'purchaseDate': subscription.purchaseDate.toIso8601String(),
      'expiryDate': subscription.expiryDate?.toIso8601String(),
      'isActive': subscription.isActive,
      'platform': subscription.platform,
      'originalTransactionId': subscription.originalTransactionId,
      'verificationData': subscription.verificationData,
      'gracePeriodUntil': subscription.gracePeriodUntil?.toIso8601String(),
    };
    final cacheData = jsonEncode(jsonMap);
    final integrity = _generateCacheIntegrity(cacheData);
    await prefs.setString(_cacheKey, cacheData);
    await prefs.setString(_cacheIntegrityKey, integrity);
  }

  Future<bool> _getCachedSubscriptionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      final cachedIntegrity = prefs.getString(_cacheIntegrityKey);

      if (cachedData == null || cachedIntegrity == null) return false;

      // Verify cache integrity
      final expectedIntegrity = _generateCacheIntegrity(cachedData);
      if (cachedIntegrity != expectedIntegrity) {
        await _clearCachedSubscription();
        return false;
      }

      final cache = jsonDecode(cachedData);
      final subscription = SubscriptionData.fromMap(cache);
      final gracePeriodUntil = subscription.gracePeriodUntil;

      if (gracePeriodUntil != null &&
          gracePeriodUntil.isAfter(DateTime.now())) {
        return subscription.isActive;
      }

      if (subscription.expiryDate != null &&
          subscription.expiryDate!.isBefore(DateTime.now())) {
        await _clearCachedSubscription();
        return false;
      }

      return subscription.isActive;
    } catch (e) {
      debugPrint('Error getting cached subscription: $e');
      return false;
    }
  }

  String _generateCacheIntegrity(String data) {
    return sha256.convert(utf8.encode('${data}salt')).toString();
  }

  Future<void> _clearCachedSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheIntegrityKey);
  }
}
