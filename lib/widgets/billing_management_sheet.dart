// widgets/billing_management_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import '../providers/premium_provider.dart';
import '../config/app_theme.dart';

class BillingManagementSheet extends ConsumerStatefulWidget {
  const BillingManagementSheet({super.key});

  @override
  ConsumerState<BillingManagementSheet> createState() =>
      _BillingManagementSheetState();
}

class _BillingManagementSheetState
    extends ConsumerState<BillingManagementSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final premiumState = ref.watch(premiumProvider);
    final theme = Theme.of(context);

    return Container(
      height: 400,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title with premium status
          Row(
            children: [
              Expanded(
                child: Text(
                  'Manage Subscription',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (premiumState.isPremium)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppTheme.premiumGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.diamond, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        premiumState.planType ?? 'Premium',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            _buildManagementOption(
              context,
              icon: Icons.refresh,
              title: 'Restore Purchases',
              subtitle: 'Restore your previous purchases',
              onTap: () => _restorePurchases(context, ref),
            ),
            _buildManagementOption(
              context,
              icon: Icons.receipt,
              title: 'View Receipts',
              subtitle: 'View purchase receipts and invoices',
              onTap: () => _viewReceipts(context),
            ),
            _buildManagementOption(
              context,
              icon: Icons.cancel,
              title: 'Cancel Subscription',
              subtitle: 'Manage your subscription in the app store',
              onTap: () => _manageSubscription(context),
            ),
            _buildManagementOption(
              context,
              icon: Icons.help,
              title: 'Billing Support',
              subtitle: 'Get help with billing questions',
              onTap: () => _contactSupport(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildManagementOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _restorePurchases(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);

    setState(() {
      _isLoading = true;
    });

    try {
      HapticFeedback.lightImpact();

      // Show loading snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Restoring purchases...'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }

      // Restore purchases via the premium provider
      await ref.read(premiumProvider.notifier).restorePurchases();

      if (mounted) {
        final premiumState = ref.read(premiumProvider);

        if (premiumState.isPremium) {
          // Success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Purchases restored successfully! ${premiumState.planType ?? "Premium"} plan activated.',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          // No purchases found
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No previous purchases found to restore.',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to restore purchases: ${error.toString()}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _viewReceipts(BuildContext context) async {
    Navigator.pop(context);
    HapticFeedback.lightImpact();

    try {
      String url;
      if (Platform.isIOS) {
        // iOS - View purchase history in App Store
        url = 'https://apps.apple.com/account/subscriptions';
      } else {
        // Android - View purchase history in Google Play
        url = 'https://play.google.com/store/account/subscriptions';
      }

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch store app');
      }
    } catch (e) {
      // Fallback: Show dialog with manual instructions
      _showReceiptInstructionsDialog(context);
    }
  }

  void _showReceiptInstructionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.receipt_long,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'View Receipts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To view your purchase receipts:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            if (Platform.isIOS) ...[
              _buildInstructionStep(context, '1.', 'Open the Settings app'),
              _buildInstructionStep(context, '2.', 'Tap your name at the top'),
              _buildInstructionStep(context, '3.', 'Tap "Media & Purchases"'),
              _buildInstructionStep(context, '4.', 'Tap "Purchase History"'),
            ] else ...[
              _buildInstructionStep(context, '1.', 'Open Google Play Store'),
              _buildInstructionStep(context, '2.', 'Tap your profile icon'),
              _buildInstructionStep(
                  context, '3.', 'Tap "Payments & subscriptions"'),
              _buildInstructionStep(context, '4.', 'Tap "Budget & history"'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(
      BuildContext context, String number, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _manageSubscription(BuildContext context) async {
    Navigator.pop(context);
    HapticFeedback.lightImpact();

    try {
      String url;
      if (Platform.isIOS) {
        url = 'https://apps.apple.com/account/subscriptions';
      } else {
        url = 'https://play.google.com/store/account/subscriptions';
      }

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not open subscription management');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Could not open subscription management. Please visit your ${Platform.isIOS ? "App Store" : "Google Play"} account manually.',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _contactSupport(BuildContext context) async {
    Navigator.pop(context);
    HapticFeedback.lightImpact();

    const email = 'support@aivisionpro.com';
    const subject = 'Billing Support Request';

    // Get current subscription info for context
    final premiumState = ref.read(premiumProvider);
    final deviceInfo = Platform.isIOS ? 'iOS' : 'Android';

    final body = '''
Hi AI Vision Pro Support,

I need assistance with my billing/subscription.

Current subscription: ${premiumState.isPremium ? (premiumState.planType ?? 'Premium') : 'None'}
Platform: $deviceInfo
${premiumState.expiryDate != null ? 'Expires: ${premiumState.expiryDate!.toLocal().toString().split(' ')[0]}' : ''}

Please describe your issue below:
[Your message here]

Thank you for your help!
''';

    final uri = Uri.parse(
      'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Fallback: Show email and copy to clipboard
        _showEmailFallback(context, email);
      }
    } catch (e) {
      _showEmailFallback(context, email);
    }
  }

  void _showEmailFallback(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.email,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Contact Support',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Email us directly for billing support:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: email));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Email copied to clipboard'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.copy,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
