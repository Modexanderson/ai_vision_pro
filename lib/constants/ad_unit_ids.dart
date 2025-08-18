// constants/ad_unit_ids.dart - UPDATED FOR PRODUCTION
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdUnitIds {
  // Check if we're in debug mode to determine test vs production ads
  static bool get _isDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  // Environment-based configuration
  static bool get _useTestAds =>
      _isDebugMode || dotenv.env['ENVIRONMENT'] == 'development';

  // ============================================================================
  // BANNER AD UNIT IDS
  // ============================================================================
  static String get bannerAdUnitId {
    if (_useTestAds) {
      // Test IDs
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    } else {
      // Production IDs from .env
      return Platform.isAndroid
          ? dotenv.env['ADMOB_BANNER_ANDROID_ID'] ??
              'ca-app-pub-3940256099942544/6300978111' // Fallback to test
          : dotenv.env['ADMOB_BANNER_IOS_ID'] ??
              'ca-app-pub-3940256099942544/2934735716'; // Fallback to test
    }
  }

  // ============================================================================
  // INTERSTITIAL AD UNIT IDS
  // ============================================================================
  static String get interstitialAdUnitId {
    if (_useTestAds) {
      // Test IDs
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    } else {
      // Production IDs from .env
      return Platform.isAndroid
          ? dotenv.env['ADMOB_INTERSTITIAL_ANDROID_ID'] ??
              'ca-app-pub-3940256099942544/1033173712' // Fallback to test
          : dotenv.env['ADMOB_INTERSTITIAL_IOS_ID'] ??
              'ca-app-pub-3940256099942544/4411468910'; // Fallback to test
    }
  }

  // ============================================================================
  // REWARDED AD UNIT IDS
  // ============================================================================
  static String get rewardedAdUnitId {
    if (_useTestAds) {
      // Test IDs
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313';
    } else {
      // Production IDs from .env
      return Platform.isAndroid
          ? dotenv.env['ADMOB_REWARDED_ANDROID_ID'] ??
              'ca-app-pub-3940256099942544/5224354917' // Fallback to test
          : dotenv.env['ADMOB_REWARDED_IOS_ID'] ??
              'ca-app-pub-3940256099942544/1712485313'; // Fallback to test
    }
  }

  // ============================================================================
  // ADMOB APP ID
  // ============================================================================
  static String get appId {
    if (_useTestAds) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544~3347511713'
          : 'ca-app-pub-3940256099942544~1458002511';
    } else {
      return Platform.isAndroid
          ? dotenv.env['ADMOB_APP_ID_ANDROID'] ??
              'ca-app-pub-3940256099942544~3347511713' // Fallback to test
          : dotenv.env['ADMOB_APP_ID_IOS'] ??
              'ca-app-pub-3940256099942544~1458002511'; // Fallback to test
    }
  }

  // ============================================================================
  // IN-APP PURCHASE PRODUCT IDS
  // ============================================================================
  static String get monthlyProductId {
    final envProductId = Platform.isIOS
        ? dotenv.env['IAP_PREMIUM_MONTHLY_IOS']
        : dotenv.env['IAP_PREMIUM_MONTHLY_ANDROID'];

    return envProductId ??
        (Platform.isIOS ? 'ai_vision_pro_monthly' : 'monthly_premium');
  }

  static String get yearlyProductId {
    final envProductId = Platform.isIOS
        ? dotenv.env['IAP_PREMIUM_YEARLY_IOS']
        : dotenv.env['IAP_PREMIUM_YEARLY_ANDROID'];

    return envProductId ??
        (Platform.isIOS ? 'ai_vision_pro_yearly' : 'yearly_premium');
  }

  static Set<String> get allProductIds => {
        monthlyProductId,
        yearlyProductId,
      };

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Check if ads are enabled in the current environment
  static bool get areAdsEnabled {
    return dotenv.env['ENABLE_ADS']?.toLowerCase() == 'true';
  }

  /// Check if we're using test ads
  static bool get usingTestAds => _useTestAds;

  /// Get ad configuration info for debugging
  static Map<String, dynamic> get adConfig => {
        'environment': dotenv.env['ENVIRONMENT'] ?? 'unknown',
        'using_test_ads': _useTestAds,
        'ads_enabled': areAdsEnabled,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'banner_id': bannerAdUnitId,
        'interstitial_id': interstitialAdUnitId,
        'rewarded_id': rewardedAdUnitId,
        'app_id': appId,
      };

  /// Print configuration for debugging
  static void printAdConfig() {
    debugPrint('=== AdMob Configuration ===');
    adConfig.forEach((key, value) {
      debugPrint('$key: $value');
    });
    debugPrint('========================');
  }
}
