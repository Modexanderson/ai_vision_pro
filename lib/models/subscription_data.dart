import 'package:cloud_firestore/cloud_firestore.dart';

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
  final DateTime? gracePeriodUntil;

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
    this.gracePeriodUntil,
  });

  // For Firestore: Uses Timestamp
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
      'gracePeriodUntil': gracePeriodUntil?.toIso8601String(),
      'lastValidated': FieldValue.serverTimestamp(),
    };
  }

  // Helper to parse dates flexibly (Timestamp from Firestore, String from cache)
  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    } else if (value is int) {
      // Optional: Handle milliseconds if needed
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    throw Exception('Invalid date format: $value');
  }

  factory SubscriptionData.fromMap(Map<String, dynamic> map) {
    return SubscriptionData(
      userId: map['userId'] ?? '',
      productId: map['productId'] ?? '',
      transactionId: map['transactionId'] ?? '',
      purchaseDate: _parseDate(map['purchaseDate']),
      expiryDate:
          map['expiryDate'] != null ? _parseDate(map['expiryDate']) : null,
      isActive: map['isActive'] ?? false,
      platform: map['platform'] ?? '',
      originalTransactionId: map['originalTransactionId'],
      verificationData: map['verificationData'],
      cancelledAt:
          map['cancelledAt'] != null ? _parseDate(map['cancelledAt']) : null,
      gracePeriodUntil: map['gracePeriodUntil'] != null
          ? DateTime.parse(map['gracePeriodUntil'] as String)
          : null,
    );
  }

  // For JSON caching: Uses encodable strings (add this and use in SubscriptionService._cacheSubscriptionStatus)
  Map<String, dynamic> toJsonMap() {
    return {
      'userId': userId,
      'productId': productId,
      'transactionId': transactionId,
      'purchaseDate': purchaseDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'isActive': isActive,
      'platform': platform,
      'originalTransactionId': originalTransactionId,
      'verificationData': verificationData,
      'cancelledAt': cancelledAt?.toIso8601String(),
      'gracePeriodUntil': gracePeriodUntil?.toIso8601String(),
    };
  }

  bool get isExpired {
    if (expiryDate == null) return false; // No expiry for valid subscriptions
    return DateTime.now().isAfter(expiryDate!);
  }

  int get daysUntilExpiry {
    if (expiryDate == null) return -1; // No expiry
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  String get planName {
    if (productId.contains('monthly') || productId.contains('test_monthly')) {
      return 'Monthly';
    } else if (productId.contains('yearly') ||
        productId.contains('test_yearly')) {
      return 'Yearly';
    }
    return 'Unknown';
  }
}
