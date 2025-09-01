// widgets/camera_settings_sheet.dart - COMPLETE IMPLEMENTATION

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/camera_provider.dart';
import '../providers/premium_provider.dart';
import '../config/app_theme.dart';

// Settings state provider for managing local settings
class CameraSettingsState {
  final bool isHDREnabled;
  final bool showGridLines;
  final bool showLevelIndicator;
  final String imageQuality;
  final String captureTimer;
  final bool shutterSoundEnabled;
  final bool hapticFeedbackEnabled;

  const CameraSettingsState({
    this.isHDREnabled = false,
    this.showGridLines = false,
    this.showLevelIndicator = false,
    this.imageQuality = 'high',
    this.captureTimer = 'off',
    this.shutterSoundEnabled = true,
    this.hapticFeedbackEnabled = true,
  });

  CameraSettingsState copyWith({
    bool? isHDREnabled,
    bool? showGridLines,
    bool? showLevelIndicator,
    String? imageQuality,
    String? captureTimer,
    bool? shutterSoundEnabled,
    bool? hapticFeedbackEnabled,
  }) {
    return CameraSettingsState(
      isHDREnabled: isHDREnabled ?? this.isHDREnabled,
      showGridLines: showGridLines ?? this.showGridLines,
      showLevelIndicator: showLevelIndicator ?? this.showLevelIndicator,
      imageQuality: imageQuality ?? this.imageQuality,
      captureTimer: captureTimer ?? this.captureTimer,
      shutterSoundEnabled: shutterSoundEnabled ?? this.shutterSoundEnabled,
      hapticFeedbackEnabled:
          hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
    );
  }
}

class CameraSettingsNotifier extends StateNotifier<CameraSettingsState> {
  CameraSettingsNotifier() : super(const CameraSettingsState());

  void toggleHDR() {
    state = state.copyWith(isHDREnabled: !state.isHDREnabled);
  }

  void toggleGridLines() {
    state = state.copyWith(showGridLines: !state.showGridLines);
  }

  void toggleLevelIndicator() {
    state = state.copyWith(showLevelIndicator: !state.showLevelIndicator);
  }

  void setImageQuality(String quality) {
    state = state.copyWith(imageQuality: quality);
  }

  void setCaptureTimer(String timer) {
    state = state.copyWith(captureTimer: timer);
  }

  void toggleShutterSound() {
    state = state.copyWith(shutterSoundEnabled: !state.shutterSoundEnabled);
  }

  void toggleHapticFeedback() {
    state = state.copyWith(hapticFeedbackEnabled: !state.hapticFeedbackEnabled);
  }

  void resetToDefaults() {
    state = const CameraSettingsState();
  }
}

final cameraSettingsProvider =
    StateNotifierProvider<CameraSettingsNotifier, CameraSettingsState>((ref) {
  return CameraSettingsNotifier();
});

class CameraSettingsSheet extends ConsumerStatefulWidget {
  const CameraSettingsSheet({super.key});

  @override
  ConsumerState<CameraSettingsSheet> createState() =>
      _CameraSettingsSheetState();
}

class _CameraSettingsSheetState extends ConsumerState<CameraSettingsSheet>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraProvider);
    final settingsState = ref.watch(cameraSettingsProvider);
    final isPremium = ref.watch(premiumProvider).isPremium;

    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _fadeController.value,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHandle(),
                  _buildHeader(context),
                  const Divider(height: 1),
                  _buildSettingsList(cameraState, settingsState, isPremium),
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Camera Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList(
    dynamic cameraState,
    CameraSettingsState settingsState,
    bool isPremium,
  ) {
    return Flexible(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: [
          _buildSettingsTile(
            icon: Icons.flash_on_rounded,
            title: 'Flash',
            subtitle: cameraState.isFlashOn ? 'On' : 'Off',
            trailing: Switch.adaptive(
              value: cameraState.isFlashOn,
              onChanged: (value) async {
                HapticFeedback.lightImpact();
                await ref.read(cameraProvider.notifier).toggleFlash();
              },
              activeColor: AppTheme.primaryColor,
            ),
          ),
          _buildSettingsTile(
            icon: Icons.hdr_on_rounded,
            title: 'HDR',
            subtitle: settingsState.isHDREnabled ? 'Enabled' : 'Disabled',
            trailing: Switch.adaptive(
              value: settingsState.isHDREnabled,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                ref.read(cameraSettingsProvider.notifier).toggleHDR();
                _showFeatureSnackBar('HDR ${value ? 'enabled' : 'disabled'}');
              },
              activeColor: AppTheme.primaryColor,
            ),
            isPremium: true,
            userIsPremium: isPremium,
          ),
          _buildSettingsTile(
            icon: Icons.grid_3x3_rounded,
            title: 'Grid Lines',
            subtitle: settingsState.showGridLines
                ? 'Showing composition grid'
                : 'Hidden',
            trailing: Switch.adaptive(
              value: settingsState.showGridLines,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                ref.read(cameraSettingsProvider.notifier).toggleGridLines();
                _showFeatureSnackBar(
                    'Grid lines ${value ? 'enabled' : 'disabled'}');
              },
              activeColor: AppTheme.primaryColor,
            ),
          ),
          _buildSettingsTile(
            icon: Icons.straighten_rounded,
            title: 'Level Indicator',
            subtitle: settingsState.showLevelIndicator
                ? 'Showing device orientation'
                : 'Hidden',
            trailing: Switch.adaptive(
              value: settingsState.showLevelIndicator,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                ref
                    .read(cameraSettingsProvider.notifier)
                    .toggleLevelIndicator();
                _showFeatureSnackBar(
                    'Level indicator ${value ? 'enabled' : 'disabled'}');
              },
              activeColor: AppTheme.primaryColor,
            ),
            isPremium: true,
            userIsPremium: isPremium,
          ),
          _buildSettingsTile(
            icon: Icons.photo_size_select_actual_rounded,
            title: 'Image Quality',
            subtitle: _getQualityDisplayName(settingsState.imageQuality),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showQualityDialog(),
          ),
          _buildSettingsTile(
            icon: Icons.timer_rounded,
            title: 'Capture Timer',
            subtitle: _getTimerDisplayName(settingsState.captureTimer),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showTimerDialog(),
          ),
          _buildSettingsTile(
            icon: Icons.volume_up_rounded,
            title: 'Shutter Sound',
            subtitle:
                settingsState.shutterSoundEnabled ? 'Enabled' : 'Disabled',
            trailing: Switch.adaptive(
              value: settingsState.shutterSoundEnabled,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                ref.read(cameraSettingsProvider.notifier).toggleShutterSound();
                _showFeatureSnackBar(
                    'Shutter sound ${value ? 'enabled' : 'disabled'}');
              },
              activeColor: AppTheme.primaryColor,
            ),
          ),
          _buildSettingsTile(
            icon: Icons.vibration_rounded,
            title: 'Haptic Feedback',
            subtitle:
                settingsState.hapticFeedbackEnabled ? 'Enabled' : 'Disabled',
            trailing: Switch.adaptive(
              value: settingsState.hapticFeedbackEnabled,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                ref
                    .read(cameraSettingsProvider.notifier)
                    .toggleHapticFeedback();
                _showFeatureSnackBar(
                    'Haptic feedback ${value ? 'enabled' : 'disabled'}');
              },
              activeColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isPremium = false,
    bool userIsPremium = true,
  }) {
    final isEnabled = !isPremium || userIsPremium;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isEnabled
                ? AppTheme.primaryColor.withOpacity(0.1)
                : Theme.of(context).disabledColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isEnabled
                ? AppTheme.primaryColor
                : Theme.of(context).disabledColor,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isEnabled ? null : Theme.of(context).disabledColor,
                    ),
              ),
            ),
            if (isPremium && !userIsPremium)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  gradient: AppTheme.premiumGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.diamond_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'PRO',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isEnabled
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).disabledColor,
              ),
        ),
        trailing: trailing,
        onTap: isEnabled ? onTap : () => _showPremiumRequired(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _showResetConfirmation();
              },
              icon: const Icon(Icons.restore_rounded),
              label: const Text('Reset to Defaults'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Done'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQualityDialog() {
    final settingsState = ref.read(cameraSettingsProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.photo_size_select_actual_rounded,
              color: AppTheme.primaryColor,
            ),
            SizedBox(width: 12),
            Text('Image Quality'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQualityOption('high', 'High',
                'Best quality, larger file size', settingsState.imageQuality),
            _buildQualityOption('medium', 'Medium', 'Balanced quality and size',
                settingsState.imageQuality),
            _buildQualityOption('low', 'Low', 'Smaller size, faster processing',
                settingsState.imageQuality),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildQualityOption(
      String value, String title, String description, String currentValue) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        description,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      value: value,
      groupValue: currentValue,
      onChanged: (newValue) {
        if (newValue != null) {
          HapticFeedback.lightImpact();
          ref.read(cameraSettingsProvider.notifier).setImageQuality(newValue);
          Navigator.pop(context);
          _showFeatureSnackBar(
              'Image quality set to ${_getQualityDisplayName(newValue)}');
        }
      },
      activeColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showTimerDialog() {
    final settingsState = ref.read(cameraSettingsProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.timer_rounded,
              color: AppTheme.primaryColor,
            ),
            SizedBox(width: 12),
            Text('Capture Timer'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTimerOption(
                'off', 'Off', 'Instant capture', settingsState.captureTimer),
            _buildTimerOption('3', '3 seconds', 'Short delay for selfies',
                settingsState.captureTimer),
            _buildTimerOption('5', '5 seconds', 'Medium delay to get ready',
                settingsState.captureTimer),
            _buildTimerOption('10', '10 seconds', 'Long delay for group photos',
                settingsState.captureTimer),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildTimerOption(
      String value, String title, String description, String currentValue) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        description,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      value: value,
      groupValue: currentValue,
      onChanged: (newValue) {
        if (newValue != null) {
          HapticFeedback.lightImpact();
          ref.read(cameraSettingsProvider.notifier).setCaptureTimer(newValue);
          Navigator.pop(context);
          _showFeatureSnackBar(
              'Timer set to ${_getTimerDisplayName(newValue)}');
        }
      },
      activeColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.restore_rounded,
              color: AppTheme.warningColor,
            ),
            SizedBox(width: 12),
            Text('Reset Settings'),
          ],
        ),
        content: const Text(
          'This will reset all camera settings to their default values. Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(cameraSettingsProvider.notifier).resetToDefaults();
              Navigator.pop(context);
              Navigator.pop(context);
              _showFeatureSnackBar('Settings reset to defaults');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  void _showPremiumRequired() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.diamond_rounded,
              color: AppTheme.premiumGold,
            ),
            SizedBox(width: 12),
            Text('Premium Required'),
          ],
        ),
        content: const Text(
          'This feature requires a premium subscription. Upgrade now to unlock advanced camera settings and enhanced functionality.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.premiumGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/premium');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Upgrade',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  void _showFeatureSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getQualityDisplayName(String quality) {
    switch (quality) {
      case 'high':
        return 'High (Best Quality)';
      case 'medium':
        return 'Medium (Balanced)';
      case 'low':
        return 'Low (Fast Processing)';
      default:
        return 'High';
    }
  }

  String _getTimerDisplayName(String timer) {
    switch (timer) {
      case 'off':
        return 'Off';
      case '3':
        return '3 seconds';
      case '5':
        return '5 seconds';
      case '10':
        return '10 seconds';
      default:
        return 'Off';
    }
  }
}
