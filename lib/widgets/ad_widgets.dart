// widgets/ad_widgets.dart - Reusable Ad Widgets

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/ads_provider.dart';
import '../providers/premium_provider.dart';

// ============================================================================
// BANNER AD WIDGET - Reusable for different screens
// ============================================================================

class AdBanner extends ConsumerStatefulWidget {
  final String placement;
  final AdSize adSize;
  final EdgeInsets margin;

  const AdBanner({
    super.key,
    required this.placement,
    this.adSize = AdSize.banner,
    this.margin = const EdgeInsets.all(8),
  });

  @override
  ConsumerState<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends ConsumerState<AdBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    final isPremium = ref.read(premiumProvider).isPremium;
    if (isPremium) return;

    // Create a unique banner ad for this widget instance
    _bannerAd = BannerAd(
      adUnitId: _getAdUnitId(),
      size: widget.adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          print('AdBanner ${widget.placement} failed: $error');
          ad.dispose();
          if (mounted) {
            setState(() => _isLoaded = false);
          }
          // Retry after delay
          Future.delayed(const Duration(seconds: 30), () {
            if (mounted) _loadBannerAd();
          });
        },
      ),
    );

    _bannerAd!.load();
  }

  String _getAdUnitId() {
    // Use test IDs or get from your AdUnitIds class
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test banner ID
    } else {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test banner ID
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(premiumProvider).isPremium;

    // Don't show ads to premium users
    if (isPremium || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      ),
    );
  }
}

// ============================================================================
// INTERSTITIAL AD TRIGGER - Use throughout the app
// ============================================================================

class InterstitialAdTrigger extends ConsumerWidget {
  final Widget child;
  final String trigger;
  final VoidCallback? onAdDismissed;

  const InterstitialAdTrigger({
    super.key,
    required this.child,
    required this.trigger,
    this.onAdDismissed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        final isPremium = ref.read(premiumProvider).isPremium;
        if (!isPremium) {
          // Show interstitial ad before action
          ref.read(adsProvider.notifier).showInterstitialAd(
                onAdDismissed: onAdDismissed,
              );
        } else {
          onAdDismissed?.call();
        }
      },
      child: child,
    );
  }
}

// ============================================================================
// REWARDED AD BUTTON - For premium features
// ============================================================================

class RewardedAdButton extends ConsumerStatefulWidget {
  final String featureName;
  final VoidCallback onRewardEarned;
  final Widget child;

  const RewardedAdButton({
    super.key,
    required this.featureName,
    required this.onRewardEarned,
    required this.child,
  });

  @override
  ConsumerState<RewardedAdButton> createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends ConsumerState<RewardedAdButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(premiumProvider).isPremium;
    final adsState = ref.watch(adsProvider);

    if (isPremium) {
      // Premium users get direct access
      return GestureDetector(
        onTap: widget.onRewardEarned,
        child: widget.child,
      );
    }

    return GestureDetector(
      onTap: _isLoading ? null : _showRewardedAd,
      child: Stack(
        children: [
          widget.child,
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          if (!adsState.isRewardedLoaded)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'AD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showRewardedAd() {
    setState(() => _isLoading = true);

    ref.read(adsProvider.notifier).showRewardedAd(
      onUserEarnedReward: (ad, reward) {
        // User earned reward, grant access to feature
        widget.onRewardEarned();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Unlocked ${widget.featureName}! Thanks for watching the ad.'),
            backgroundColor: Colors.green,
          ),
        );
      },
      onAdDismissed: () {
        setState(() => _isLoading = false);
      },
      onAdFailedToShow: () {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ad not available. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }
}

// ============================================================================
// AD-SUPPORTED FREE TRIAL WIDGET
// ============================================================================

class AdSupportedFeature extends ConsumerWidget {
  final String featureName;
  final String description;
  final Widget child;
  final VoidCallback onFeatureUnlocked;

  const AdSupportedFeature({
    super.key,
    required this.featureName,
    required this.description,
    required this.child,
    required this.onFeatureUnlocked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(premiumProvider).isPremium;

    if (isPremium) {
      return child;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Opacity(opacity: 0.5, child: child),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_circle_filled,
                      color: Colors.orange, size: 48),
                  const SizedBox(height: 8),
                  const Text(
                    'Watch Ad to Use',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  RewardedAdButton(
                    featureName: featureName,
                    onRewardEarned: onFeatureUnlocked,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Watch Ad',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// NATIVE AD WIDGET (for content feeds)
// ============================================================================

class NativeAdWidget extends ConsumerStatefulWidget {
  final String placement;

  const NativeAdWidget({
    super.key,
    required this.placement,
  });

  @override
  ConsumerState<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends ConsumerState<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  void _loadNativeAd() {
    final isPremium = ref.read(premiumProvider).isPremium;
    if (isPremium) return;

    _nativeAd = NativeAd(
      adUnitId: 'ca-app-pub-3940256099942544/2247696110', // Test native ID
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          print('NativeAd ${widget.placement} failed: $error');
          ad.dispose();
          if (mounted) {
            setState(() => _isLoaded = false);
          }
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.white,
        cornerRadius: 10.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: Colors.blue,
          style: NativeTemplateFontStyle.monospace,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.grey,
          style: NativeTemplateFontStyle.italic,
          size: 14.0,
        ),
      ),
    );

    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(premiumProvider).isPremium;

    if (isPremium || !_isLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(8),
      height: 320,
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
