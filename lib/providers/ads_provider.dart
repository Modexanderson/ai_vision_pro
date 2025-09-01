// providers/ads_provider.dart - SIMPLIFIED VERSION (Remove banner ad management)

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../models/ads_state.dart';
import '../constants/ad_unit_ids.dart';

class AdsNotifier extends StateNotifier<AdsState> {
  AdsNotifier() : super(AdsState()) {
    _initialize();
  }

  // Ad frequency control
  int _interstitialCounter = 0;
  final int _rewardedCounter = 0;
  DateTime? _lastInterstitialTime;
  DateTime? _lastRewardedTime;

  // Ad display settings
  static const int interstitialFrequency = 3; // Show every 3 actions
  static const int minTimeBetweenInterstitials = 60; // 60 seconds minimum
  static const int minTimeBetweenRewarded = 30; // 30 seconds minimum

  bool get _areAdsEnabled => AdUnitIds.areAdsEnabled;

  void _initialize() {
    if (kDebugMode) {
      AdUnitIds.printAdConfig();
    }

    if (_areAdsEnabled) {
      // Only preload interstitial and rewarded ads
      // Banner ads are now managed by individual widgets
      loadInterstitialAd();
      loadRewardedAd();
    }
  }

  // ============================================================================
  // BANNER ADS - REMOVED (now managed by individual AdBanner widgets)
  // ============================================================================

  // Remove all banner ad methods - they're causing conflicts

  // ============================================================================
  // INTERSTITIAL ADS - Improved frequency and timing
  // ============================================================================

  void loadInterstitialAd() {
    if (!_areAdsEnabled) return;

    InterstitialAd.load(
      adUnitId: AdUnitIds.interstitialAdUnitId,
      request: _createAdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (kDebugMode) debugPrint('Interstitial ad loaded');
          state = state.copyWith(
            interstitialAd: ad,
            isInterstitialLoaded: true,
            error: null,
          );
          ad.setImmersiveMode(true);
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) debugPrint('Interstitial ad failed: $error');
          state = state.copyWith(
            interstitialAd: null,
            isInterstitialLoaded: false,
            error: 'Interstitial ad failed: ${error.message}',
          );
          // Retry loading
          Future.delayed(const Duration(seconds: 60), () {
            if (mounted) loadInterstitialAd();
          });
        },
      ),
    );
  }

  // Show interstitial with smart frequency control
  void showInterstitialAd({VoidCallback? onAdDismissed, bool force = false}) {
    if (!_areAdsEnabled) {
      onAdDismissed?.call();
      return;
    }

    // Check frequency and timing
    if (!force && !_shouldShowInterstitial()) {
      onAdDismissed?.call();
      return;
    }

    if (!state.isInterstitialLoaded || state.interstitialAd == null) {
      if (kDebugMode) debugPrint('Interstitial ad not ready');
      loadInterstitialAd();
      onAdDismissed?.call();
      return;
    }

    // Update counters
    _interstitialCounter = 0;
    _lastInterstitialTime = DateTime.now();

    state.interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        if (kDebugMode) debugPrint('Interstitial ad showed');
        state = state.copyWith(isShowingAd: true);
      },
      onAdDismissedFullScreenContent: (ad) {
        if (kDebugMode) debugPrint('Interstitial ad dismissed');
        state = state.copyWith(isShowingAd: false, isInterstitialLoaded: false);
        ad.dispose();
        onAdDismissed?.call();
        // Preload next ad
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) loadInterstitialAd();
        });
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) debugPrint('Interstitial ad failed to show: $error');
        state = state.copyWith(
          isShowingAd: false,
          isInterstitialLoaded: false,
          error: 'Interstitial ad failed: ${error.message}',
        );
        ad.dispose();
        onAdDismissed?.call();
        loadInterstitialAd();
      },
    );

    state.interstitialAd!.show();
  }

  bool _shouldShowInterstitial() {
    // Check frequency
    _interstitialCounter++;
    if (_interstitialCounter < interstitialFrequency) return false;

    // Check timing
    if (_lastInterstitialTime != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastInterstitialTime!);
      if (timeSinceLastAd.inSeconds < minTimeBetweenInterstitials) return false;
    }

    return true;
  }

  // ============================================================================
  // REWARDED ADS - Enhanced functionality
  // ============================================================================

  void loadRewardedAd() {
    if (!_areAdsEnabled) return;

    RewardedAd.load(
      adUnitId: AdUnitIds.rewardedAdUnitId,
      request: _createAdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (kDebugMode) debugPrint('Rewarded ad loaded');
          state = state.copyWith(
            rewardedAd: ad,
            isRewardedLoaded: true,
            error: null,
          );
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) debugPrint('Rewarded ad failed: $error');
          state = state.copyWith(
            rewardedAd: null,
            isRewardedLoaded: false,
            error: 'Rewarded ad failed: ${error.message}',
          );
          // Retry loading
          Future.delayed(const Duration(seconds: 60), () {
            if (mounted) loadRewardedAd();
          });
        },
      ),
    );
  }

  void showRewardedAd({
    required Function(AdWithoutView ad, RewardItem reward) onUserEarnedReward,
    VoidCallback? onAdDismissed,
    VoidCallback? onAdFailedToShow,
  }) {
    if (!_areAdsEnabled) {
      onAdDismissed?.call();
      return;
    }

    // Check timing
    if (_lastRewardedTime != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastRewardedTime!);
      if (timeSinceLastAd.inSeconds < minTimeBetweenRewarded) {
        onAdFailedToShow?.call();
        return;
      }
    }

    if (!state.isRewardedLoaded || state.rewardedAd == null) {
      if (kDebugMode) debugPrint('Rewarded ad not ready');
      onAdFailedToShow?.call();
      loadRewardedAd();
      return;
    }

    _lastRewardedTime = DateTime.now();

    state.rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        if (kDebugMode) debugPrint('Rewarded ad showed');
        state = state.copyWith(isShowingAd: true);
      },
      onAdDismissedFullScreenContent: (ad) {
        if (kDebugMode) debugPrint('Rewarded ad dismissed');
        state = state.copyWith(isShowingAd: false, isRewardedLoaded: false);
        ad.dispose();
        onAdDismissed?.call();
        // Preload next ad
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) loadRewardedAd();
        });
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) debugPrint('Rewarded ad failed to show: $error');
        state = state.copyWith(
          isShowingAd: false,
          isRewardedLoaded: false,
          error: 'Rewarded ad failed: ${error.message}',
        );
        ad.dispose();
        onAdFailedToShow?.call();
        loadRewardedAd();
      },
    );

    state.rewardedAd!.show(onUserEarnedReward: onUserEarnedReward);
  }

  // ============================================================================
  // AD TRIGGERS - Methods to call throughout the app
  // ============================================================================

  void onDetectionCompleted() {
    // Show interstitial after every few detections
    showInterstitialAd();
  }

  void onScreenTransition() {
    // Show interstitial when navigating between major screens
    showInterstitialAd();
  }

  void onAppPause() {
    // Show interstitial when app comes back from background
    showInterstitialAd();
  }

  void onFeatureUsed(String feature) {
    // Show rewarded ad for premium features in free version
    if (feature == 'export' || feature == 'advanced_analysis') {
      // Offer rewarded ad for premium features
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  AdRequest _createAdRequest() {
    return const AdRequest(
      keywords: ['AI', 'camera', 'photo', 'recognition', 'technology'],
      contentUrl: 'https://aivisionpro.com',
      nonPersonalizedAds: false,
    );
  }

  bool shouldShowAds(bool isPremium) {
    return _areAdsEnabled && !isPremium;
  }

  void reloadAllAds() {
    if (_areAdsEnabled) {
      loadInterstitialAd();
      loadRewardedAd();
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    // Only dispose interstitial and rewarded ads
    // Banner ads are handled by individual widgets
    state.interstitialAd?.dispose();
    state.rewardedAd?.dispose();
    super.dispose();
  }
}

final adsProvider = StateNotifierProvider<AdsNotifier, AdsState>(
  (ref) => AdsNotifier(),
);
