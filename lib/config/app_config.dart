// config/app_config.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static late String environment;
  static late String apiBaseUrl;
  static late String openAiApiKey;
  static late String geminiApiKey;
  static late bool enablePremiumFeatures;
  static late bool enableAnalytics;
  static late String adMobAppId;
  static late String adMobBannerId;
  static late String adMobInterstitialId;
  static late String adMobRewardedId;

  static Future<void> initialize() async {
    try {
      environment = dotenv.env['ENVIRONMENT'] ?? 'development';
      apiBaseUrl = dotenv.env['API_BASE_URL'] ?? '';
      openAiApiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
      geminiApiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      enablePremiumFeatures = dotenv.env['ENABLE_PREMIUM'] == 'true';
      enableAnalytics = dotenv.env['ENABLE_ANALYTICS'] == 'true';
      adMobAppId = dotenv.env['ADMOB_APP_ID'] ?? '';
      adMobBannerId = dotenv.env['ADMOB_BANNER_ID'] ?? '';
      adMobInterstitialId = dotenv.env['ADMOB_INTERSTITIAL_ID'] ?? '';
      adMobRewardedId = dotenv.env['ADMOB_REWARDED_ID'] ?? '';
    } catch (e) {
      // Use default values if .env loading fails
      environment = 'development';
      apiBaseUrl = '';
      openAiApiKey = '';
      geminiApiKey = '';
      enablePremiumFeatures = true;
      enableAnalytics = false;
      adMobAppId = '';
      adMobBannerId = '';
      adMobInterstitialId = '';
      adMobRewardedId = '';

      debugPrint('Warning: Failed to load .env file, using defaults');
    }
  }

  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
}
