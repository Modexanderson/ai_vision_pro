import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../constants/ad_unit_ids.dart';
import '../models/premium_plan.dart';
import '../models/premium_state.dart';
import '../services/subscription_service.dart';

class PremiumNotifier extends StateNotifier<PremiumState> {
  PremiumNotifier() : super(PremiumState()) {
    _initialize();
  }

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final SubscriptionService _subscriptionService = SubscriptionService();
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  Timer? _validationTimer;

  // Firebase Functions base URL (non-const to allow dotenv access)
  static String get _functionsBaseUrl =>
      'https://us-central1-${dotenv.env['FIREBASE_PROJECT_ID'] ?? 'aivisionpro'}.cloudfunctions.net';

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      // Check store availability
      final bool isAvailable = await _inAppPurchase.isAvailable();
      if (!isAvailable) {
        state = state.copyWith(
          isLoading: false,
          isStoreAvailable: false,
          error: 'In-app purchases are not available on this device',
        );
        return;
      }

      // Load existing subscription status
      await _loadSubscriptionStatus();

      // Listen to purchase updates
      final Stream<List<PurchaseDetails>> purchaseUpdated =
          _inAppPurchase.purchaseStream;
      _subscription = purchaseUpdated.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription.cancel(),
        onError: (error) {
          debugPrint('Purchase stream error: $error');
          state = state.copyWith(error: 'Purchase stream error: $error');
        },
      );

      // Load available products
      await _loadProducts();

      // Start periodic validation
      _startPeriodicValidation();

      state = state.copyWith(
        isLoading: false,
        isStoreAvailable: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize premium system: $e',
      );
    }
  }

  Future<void> _loadSubscriptionStatus() async {
    try {
      final hasActive = await _subscriptionService.hasActiveSubscription();
      final details = await _subscriptionService.getSubscriptionDetails();

      if (hasActive && details != null) {
        state = state.copyWith(
          isPremium: true,
          planType: details.planName,
          expiryDate: details.expiryDate,
          purchaseDate: details.purchaseDate,
        );
      } else {
        state = state.copyWith(
          isPremium: false,
          planType: null,
          expiryDate: null,
          purchaseDate: null,
        );
      }
    } catch (e) {
      debugPrint('Failed to load subscription status: $e');
    }
  }

  Future<void> _loadProducts() async {
    try {
      final productIds = AdUnitIds.allProductIds;
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(productIds);

      if (response.error != null) {
        state = state.copyWith(
          error: 'Failed to load products: ${response.error!.message}',
        );
        return;
      }

      state = state.copyWith(
        availableProducts: response.productDetails,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load products: $e',
      );
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchaseUpdate(purchaseDetails);
    }
  }

  Future<void> _handlePurchaseUpdate(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.pending) {
      state = state.copyWith(isLoading: true);
    } else if (purchaseDetails.status == PurchaseStatus.error) {
      state = state.copyWith(
        isLoading: false,
        error:
            'Purchase failed: ${purchaseDetails.error?.message ?? "Unknown error"}',
      );
    } else if (purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored) {
      await _handleSuccessfulPurchase(purchaseDetails);
    } else if (purchaseDetails.status == PurchaseStatus.canceled) {
      state = state.copyWith(
        isLoading: false,
        error: 'Purchase was cancelled',
      );
    }

    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  Future<void> _handleSuccessfulPurchase(
      PurchaseDetails purchaseDetails) async {
    try {
      // Calculate expiry date based on product
      DateTime? expiryDate;
      String planType;

      switch (purchaseDetails.productID) {
        case SubscriptionService.monthlyProductId:
          planType = 'Monthly';
          expiryDate = DateTime.now().add(const Duration(days: 30));
          break;
        case SubscriptionService.yearlyProductId:
          planType = 'Yearly';
          expiryDate = DateTime.now().add(const Duration(days: 365));
          break;
        default:
          throw Exception('Invalid product ID: ${purchaseDetails.productID}');
      }

      // Verify purchase with server
      await _verifyPurchaseWithServer(purchaseDetails);

      // Save subscription to Firestore and cache
      await _subscriptionService.saveSubscription(
        productId: purchaseDetails.productID,
        transactionId: purchaseDetails.purchaseID ?? '',
        purchaseDate: DateTime.now(),
        expiryDate: expiryDate,
        purchaseDetails: purchaseDetails,
      );

      // Update state
      state = state.copyWith(
        isPremium: true,
        planType: planType,
        expiryDate: expiryDate,
        purchaseDate: DateTime.now(),
        isLoading: false,
        error: null,
      );

      _trackPremiumUpgrade(planType);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to process purchase: $e',
      );
    }
  }

  Future<void> _verifyPurchaseWithServer(PurchaseDetails purchase) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await http.post(
        Uri.parse('$_functionsBaseUrl/process_subscription'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': user.uid,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'productId': purchase.productID,
          'purchaseData': {
            'transactionId': purchase.purchaseID,
            'purchaseToken': purchase.verificationData.localVerificationData,
            'receipt': Platform.isIOS
                ? purchase.verificationData.serverVerificationData
                : null,
          },
        }),
      );

      if (response.statusCode != 200 || !jsonDecode(response.body)['success']) {
        throw Exception('Server failed to verify purchase');
      }

      debugPrint('Purchase verification successful: ${response.body}');
    } catch (e) {
      debugPrint('Purchase verification failed: $e');
      throw Exception('Failed to verify purchase: $e');
    }
  }

  void _startPeriodicValidation() {
    // Validate subscription every hour
    _validationTimer = Timer.periodic(const Duration(hours: 1), (timer) async {
      if (state.isPremium) {
        final isValid = await _subscriptionService.hasActiveSubscription();
        if (!isValid && mounted) {
          // Subscription is no longer valid
          state = state.copyWith(
            isPremium: false,
            planType: null,
            expiryDate: null,
            purchaseDate: null,
          );
        }
      }
    });
  }

  // Public methods
  Future<bool> purchaseSubscription(String productId) async {
    if (!state.isStoreAvailable) {
      state = state.copyWith(error: 'Store is not available');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final ProductDetails? productDetails = state.availableProducts
          .where((product) => product.id == productId)
          .firstOrNull;

      if (productDetails == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Product not found: $productId',
        );
        return false;
      }

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!success) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to initiate purchase',
        );
        return false;
      }

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Purchase failed: $e',
      );
      return false;
    }
  }

  Future<void> restorePurchases() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final restoredSubscriptions =
          await _subscriptionService.restorePurchases();

      if (restoredSubscriptions.isNotEmpty) {
        final subscription = restoredSubscriptions.first;
        state = state.copyWith(
          isPremium: subscription.isActive && !subscription.isExpired,
          planType: subscription.planName,
          expiryDate: subscription.expiryDate,
          purchaseDate: subscription.purchaseDate,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isPremium: false,
          planType: null,
          expiryDate: null,
          purchaseDate: null,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to restore purchases: $e',
      );
    }
  }

  Future<void> cancelSubscription() async {
    try {
      await _subscriptionService.cancelSubscription();

      state = state.copyWith(
        isPremium: false,
        planType: null,
        expiryDate: null,
        purchaseDate: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to cancel subscription: $e');
    }
  }

  ProductDetails? getProductDetails(String productId) {
    return state.availableProducts
        .where((product) => product.id == productId)
        .firstOrNull;
  }

  List<PremiumPlan> getAvailablePlans() {
    final plans = <PremiumPlan>[];

    for (final product in state.availableProducts) {
      switch (product.id) {
        case SubscriptionService.monthlyProductId:
          plans.add(PremiumPlan(
            id: product.id,
            title: 'Monthly',
            description: 'Perfect for trying out premium features',
            price: _parsePrice(product.price),
            period: '/month',
            features: [
              'Real-time detection',
              'Advanced analytics',
              'Cloud sync',
              'Unlimited scans',
              'Priority support',
              'Ad-free experience',
            ],
          ));
          break;
        case SubscriptionService.yearlyProductId:
          plans.add(PremiumPlan(
            id: product.id,
            title: 'Yearly',
            description: 'Best value for regular users',
            price: _parsePrice(product.price),
            period: '/year',
            isPopular: true,
            discountPercent: 33,
            features: [
              'Everything in Monthly',
              'Advanced AI models',
              'Batch processing',
              'Export features',
              'API access',
              '33% savings',
            ],
          ));
          break;
      }
    }

    return plans;
  }

  double _parsePrice(String price) {
    // Extract numeric value from price string
    final numericString = price.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(numericString) ?? 0.0;
  }

  void _trackPremiumUpgrade(String planType) {
    debugPrint('Premium upgrade tracked: $planType');
    // Implement analytics tracking here
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _validationTimer?.cancel();
    super.dispose();
  }
}

final premiumProvider = StateNotifierProvider<PremiumNotifier, PremiumState>(
  (ref) => PremiumNotifier(),
);
