// models/subscription_data.dart

// Data model for subscription
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/subscription_service.dart';

class SubscriptionData {
  final String userId;
  final String productId;
  final String transactionId;
  final DateTime purchaseDate;
  final DateTime? expiryDate;
  final bool isActive;
  final String platform;
  final String? originalTransactionId;
  final String? verificationData;
  final DateTime? cancelledAt;

  SubscriptionData({
    required this.userId,
    required this.productId,
    required this.transactionId,
    required this.purchaseDate,
    this.expiryDate,
    required this.isActive,
    required this.platform,
    this.originalTransactionId,
    this.verificationData,
    this.cancelledAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'productId': productId,
      'transactionId': transactionId,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'isActive': isActive,
      'platform': platform,
      'originalTransactionId': originalTransactionId,
      'verificationData': verificationData,
      'cancelledAt':
          cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'lastValidated': FieldValue.serverTimestamp(),
    };
  }

  factory SubscriptionData.fromMap(Map<String, dynamic> map) {
    return SubscriptionData(
      userId: map['userId'] ?? '',
      productId: map['productId'] ?? '',
      transactionId: map['transactionId'] ?? '',
      purchaseDate: (map['purchaseDate'] as Timestamp).toDate(),
      expiryDate: map['expiryDate'] != null
          ? (map['expiryDate'] as Timestamp).toDate()
          : null,
      isActive: map['isActive'] ?? false,
      platform: map['platform'] ?? '',
      originalTransactionId: map['originalTransactionId'],
      verificationData: map['verificationData'],
      cancelledAt: map['cancelledAt'] != null
          ? (map['cancelledAt'] as Timestamp).toDate()
          : null,
    );
  }

  bool get isExpired {
    if (expiryDate == null) return false; // Lifetime purchase
    return DateTime.now().isAfter(expiryDate!);
  }

  int get daysUntilExpiry {
    if (expiryDate == null) return -1; // Lifetime
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  String get planName {
    switch (productId) {
      case SubscriptionService.monthlyProductId:
        return 'Monthly';
      case SubscriptionService.yearlyProductId:
        return 'Yearly';
      case SubscriptionService.lifetimeProductId:
        return 'Lifetime';
      default:
        return 'Unknown';
    }
  }
}
