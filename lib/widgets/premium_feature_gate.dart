// Premium Feature Gate Widget
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/premium_provider.dart';

class PremiumFeatureGate extends ConsumerWidget {
  final String feature;
  final String description;
  final Widget child;
  final bool showUpgradeButton;

  const PremiumFeatureGate({
    super.key,
    required this.feature,
    required this.description,
    required this.child,
    this.showUpgradeButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(premiumProvider).isPremium;

    if (isPremium) {
      return child;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber, Colors.orange],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.diamond,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            feature,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (showUpgradeButton)
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/premium'),
              icon: const Icon(Icons.upgrade),
              label: const Text('Upgrade to Premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    ).animate().slideY(begin: 0.3).fadeIn();
  }
}
