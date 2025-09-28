// providers/app_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/premium_plan.dart';
import '../services/auto_save_service.dart';
import '../services/image_quality_manager.dart';
import '../utils/haptic_feedback.dart';
import '../utils/sound_manager.dart';
import 'premium_provider.dart';

final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(premiumProvider).isPremium;
});

final shouldShowAdsProvider = Provider<bool>((ref) {
  return !ref.watch(isPremiumProvider);
});

final premiumPlansProvider = Provider<List<PremiumPlan>>((ref) {
  return ref.watch(premiumProvider.notifier).getAvailablePlans();
});

final soundManagerProvider = Provider<SoundManager>((ref) {
  return SoundManager();
});

final hapticFeedbackProvider = Provider<HapticFeedbackUtil>((ref) {
  return HapticFeedbackUtil();
});

final imageQualityManagerProvider = Provider<ImageQualityManager>((ref) {
  return ImageQualityManager();
});

final autoSaveServiceProvider = Provider<AutoSaveService>((ref) {
  return AutoSaveService();
});
