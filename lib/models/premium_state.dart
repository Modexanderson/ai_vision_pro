// models/premium_state.dart

import 'package:in_app_purchase/in_app_purchase.dart';

class PremiumState {
  final bool isPremium;
  final String? planType;
  final DateTime? expiryDate;
  final DateTime? purchaseDate;
  final bool isLoading;
  final String? error;
  final List<ProductDetails> availableProducts;
  final bool isStoreAvailable;
  final Map<String, PurchaseDetails> purchases;

  PremiumState({
    this.isPremium = false,
    this.planType,
    this.expiryDate,
    this.purchaseDate,
    this.isLoading = false,
    this.error,
    this.availableProducts = const [],
    this.isStoreAvailable = false,
    this.purchases = const {},
  });

  PremiumState copyWith({
    bool? isPremium,
    String? planType,
    DateTime? expiryDate,
    DateTime? purchaseDate,
    bool? isLoading,
    String? error,
    List<ProductDetails>? availableProducts,
    bool? isStoreAvailable,
    Map<String, PurchaseDetails>? purchases,
  }) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      planType: planType ?? this.planType,
      expiryDate: expiryDate ?? this.expiryDate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      availableProducts: availableProducts ?? this.availableProducts,
      isStoreAvailable: isStoreAvailable ?? this.isStoreAvailable,
      purchases: purchases ?? this.purchases,
    );
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  int get daysUntilExpiry {
    if (expiryDate == null) return 0;
    return expiryDate!.difference(DateTime.now()).inDays;
  }
}
