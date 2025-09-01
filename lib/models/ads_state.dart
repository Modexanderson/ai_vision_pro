// models/ads_state.dart

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsState {
  final BannerAd? bannerAd;
  final InterstitialAd? interstitialAd;
  final RewardedAd? rewardedAd;
  final bool isBannerLoaded;
  final bool isInterstitialLoaded;
  final bool isRewardedLoaded;
  final bool isShowingAd;
  final String? error;

  AdsState({
    this.bannerAd,
    this.interstitialAd,
    this.rewardedAd,
    this.isBannerLoaded = false,
    this.isInterstitialLoaded = false,
    this.isRewardedLoaded = false,
    this.isShowingAd = false,
    this.error,
  });

  AdsState copyWith({
    BannerAd? bannerAd,
    InterstitialAd? interstitialAd,
    RewardedAd? rewardedAd,
    bool? isBannerLoaded,
    bool? isInterstitialLoaded,
    bool? isRewardedLoaded,
    bool? isShowingAd,
    String? error,
  }) {
    return AdsState(
      bannerAd: bannerAd ?? this.bannerAd,
      interstitialAd: interstitialAd ?? this.interstitialAd,
      rewardedAd: rewardedAd ?? this.rewardedAd,
      isBannerLoaded: isBannerLoaded ?? this.isBannerLoaded,
      isInterstitialLoaded: isInterstitialLoaded ?? this.isInterstitialLoaded,
      isRewardedLoaded: isRewardedLoaded ?? this.isRewardedLoaded,
      isShowingAd: isShowingAd ?? this.isShowingAd,
      error: error,
    );
  }
}
