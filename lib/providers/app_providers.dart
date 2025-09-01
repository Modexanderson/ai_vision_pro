// providers/app_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/premium_plan.dart';
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
