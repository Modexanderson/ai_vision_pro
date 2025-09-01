// import 'dart:io';

// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:package_info_plus/package_info_plus.dart';

// import '../providers/auth_provider.dart';
// import '../providers/premium_provider.dart';
// import '../config/app_theme.dart';

// class SettingsScreen extends ConsumerStatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends ConsumerState<SettingsScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _slideController;
//   late AnimationController _fadeController;

//   // Settings State
//   bool _notificationsEnabled = true;
//   bool _soundEnabled = true;
//   bool _hapticEnabled = true;
//   bool _autoSave = true;
//   bool _highQuality = true;
//   String _language = 'English';
//   String _theme = 'System';

//   // App Info
//   String _appVersion = '1.0.0';
//   String _buildNumber = '1';

//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _loadSettings();
//     _loadAppInfo();
//     _calculateCacheSize(); // Add this line
//   }

//   void _initializeAnimations() {
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );

//     _slideController.forward();
//     _fadeController.forward();
//   }

//   void _loadSettings() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       if (mounted) {
//         setState(() {
//           _notificationsEnabled =
//               prefs.getBool('notifications_enabled') ?? true;
//           _soundEnabled = prefs.getBool('sound_enabled') ?? true;
//           _hapticEnabled = prefs.getBool('haptic_enabled') ?? true;
//           _autoSave = prefs.getBool('auto_save') ?? true;
//           _highQuality = prefs.getBool('high_quality') ?? true;
//           _language = prefs.getString('language') ?? 'English';
//           _theme = prefs.getString('theme') ?? 'System';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isLoading = false);
//         _showErrorSnackBar('Failed to load settings: $e');
//       }
//     }
//   }

//   void _loadAppInfo() async {
//     try {
//       final packageInfo = await PackageInfo.fromPlatform();
//       final deviceInfo = DeviceInfoPlugin();

//       String deviceModel = 'Unknown Device';

//       if (Platform.isAndroid) {
//         final androidInfo = await deviceInfo.androidInfo;
//         deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
//       } else if (Platform.isIOS) {
//         final iosInfo = await deviceInfo.iosInfo;
//         deviceModel = '${iosInfo.name} ${iosInfo.model}';
//       }

//       if (mounted) {
//         setState(() {
//           _appVersion = packageInfo.version;
//           _buildNumber = packageInfo.buildNumber;
//           // You can store deviceModel in a variable if needed
//         });
//       }
//     } catch (e) {
//       debugPrint('Failed to load app info: $e');
//     }
//   }

//   void _saveSettings() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await Future.wait([
//         prefs.setBool('notifications_enabled', _notificationsEnabled),
//         prefs.setBool('sound_enabled', _soundEnabled),
//         prefs.setBool('haptic_enabled', _hapticEnabled),
//         prefs.setBool('auto_save', _autoSave),
//         prefs.setBool('high_quality', _highQuality),
//         prefs.setString('language', _language),
//         prefs.setString('theme', _theme),
//       ]);
//     } catch (e) {
//       _showErrorSnackBar('Failed to save settings: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _slideController.dispose();
//     _fadeController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isPremium = ref.watch(premiumProvider).isPremium;

//     if (_isLoading) {
//       return _buildLoadingScreen(theme);
//     }

//     return Scaffold(
//       backgroundColor: theme.colorScheme.surface,
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           _buildSliverAppBar(theme),
//           SliverPadding(
//             padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//             sliver: SliverList(
//               delegate: SliverChildListDelegate([
//                 // User Profile Card
//                 _buildUserProfileCard(theme).animate().slideX().fadeIn(),

//                 const SizedBox(height: 24),

//                 // Premium Banner (if not premium)
//                 if (!isPremium) ...[
//                   _buildPremiumBanner(theme)
//                       .animate(delay: 200.ms)
//                       .slideY(begin: 0.3)
//                       .fadeIn(),
//                   const SizedBox(height: 24),
//                 ],

//                 // General Settings
//                 _buildSectionHeader('General', Icons.settings_rounded, theme)
//                     .animate(delay: 300.ms)
//                     .slideX()
//                     .fadeIn(),
//                 const SizedBox(height: 12),
//                 _buildSettingsCard([
//                   _buildSwitchTile(
//                     'Push Notifications',
//                     'Receive updates and alerts',
//                     Icons.notifications_rounded,
//                     _notificationsEnabled,
//                     (value) =>
//                         _updateSetting(() => _notificationsEnabled = value),
//                     theme,
//                   ),
//                   _buildDivider(theme),
//                   _buildSwitchTile(
//                     'Sound Effects',
//                     'Audio feedback for interactions',
//                     Icons.volume_up_rounded,
//                     _soundEnabled,
//                     (value) => _updateSetting(() => _soundEnabled = value),
//                     theme,
//                   ),
//                   _buildDivider(theme),
//                   _buildSwitchTile(
//                     'Haptic Feedback',
//                     'Vibration for touch interactions',
//                     Icons.vibration_rounded,
//                     _hapticEnabled,
//                     (value) => _updateSetting(() => _hapticEnabled = value),
//                     theme,
//                   ),
//                 ], theme)
//                     .animate(delay: 400.ms)
//                     .slideY(begin: 0.3)
//                     .fadeIn(),

//                 const SizedBox(height: 24),

//                 // Camera & Detection Settings
//                 _buildSectionHeader(
//                         'Camera & Detection', Icons.camera_alt_rounded, theme)
//                     .animate(delay: 500.ms)
//                     .slideX()
//                     .fadeIn(),
//                 const SizedBox(height: 12),
//                 _buildSettingsCard([
//                   _buildSwitchTile(
//                     'High Quality Images',
//                     'Capture in maximum resolution',
//                     Icons.hd_rounded,
//                     _highQuality,
//                     (value) => _updateSetting(() => _highQuality = value),
//                     theme,
//                     badge: isPremium ? 'PRO' : null,
//                   ),
//                   _buildDivider(theme),
//                   _buildSwitchTile(
//                     'Auto-save Results',
//                     'Automatically save detections',
//                     Icons.save_rounded,
//                     _autoSave,
//                     (value) => _updateSetting(() => _autoSave = value),
//                     theme,
//                   ),
//                   _buildDivider(theme),
//                   _buildTapTile(
//                     'Camera Permissions',
//                     'Manage camera and storage access',
//                     Icons.security_rounded,
//                     () => _showPermissionsDialog(),
//                     theme,
//                   ),
//                 ], theme)
//                     .animate(delay: 600.ms)
//                     .slideY(begin: 0.3)
//                     .fadeIn(),

//                 const SizedBox(height: 24),

//                 // Appearance Settings
//                 _buildSectionHeader('Appearance', Icons.palette_rounded, theme)
//                     .animate(delay: 700.ms)
//                     .slideX()
//                     .fadeIn(),
//                 const SizedBox(height: 12),
//                 _buildSettingsCard([
//                   _buildDropdownTile(
//                     'Theme Mode',
//                     'Choose your preferred appearance',
//                     Icons.brightness_6_rounded,
//                     _theme,
//                     ['System', 'Light', 'Dark'],
//                     (value) => _updateTheme(value!),
//                     theme,
//                   ),
//                   _buildDivider(theme),
//                   _buildDropdownTile(
//                     'Language',
//                     'Select your preferred language',
//                     Icons.language_rounded,
//                     _language,
//                     [
//                       'English',
//                       'Spanish',
//                       'French',
//                       'German',
//                       'Chinese',
//                       'Japanese'
//                     ],
//                     (value) => _updateLanguage(value!),
//                     theme,
//                   ),
//                 ], theme)
//                     .animate(delay: 800.ms)
//                     .slideY(begin: 0.3)
//                     .fadeIn(),

//                 const SizedBox(height: 24),

//                 // Data & Privacy
//                 _buildSectionHeader(
//                         'Data & Privacy', Icons.privacy_tip_rounded, theme)
//                     .animate(delay: 900.ms)
//                     .slideX()
//                     .fadeIn(),
//                 const SizedBox(height: 12),
//                 _buildSettingsCard([
//                   _buildTapTile(
//                     'Clear Cache',
//                     'Free up ${_getCacheSize()} of storage space',
//                     Icons.cleaning_services_rounded,
//                     () => _clearCache(),
//                     theme,
//                   ),
//                   _buildDivider(theme),
//                   _buildTapTile(
//                     'Export Data',
//                     'Download your detection history',
//                     Icons.download_rounded,
//                     () => _exportData(),
//                     theme,
//                     badge: isPremium ? null : 'PRO',
//                   ),
//                   _buildDivider(theme),
//                   _buildTapTile(
//                     'Privacy Policy',
//                     'View our privacy practices',
//                     Icons.policy_rounded,
//                     () => _openPrivacyPolicy(),
//                     theme,
//                   ),
//                 ], theme)
//                     .animate(delay: 1000.ms)
//                     .slideY(begin: 0.3)
//                     .fadeIn(),

//                 const SizedBox(height: 24),

//                 // Support & Feedback
//                 _buildSectionHeader('Support & Feedback',
//                         Icons.support_agent_rounded, theme)
//                     .animate(delay: 1100.ms)
//                     .slideX()
//                     .fadeIn(),
//                 const SizedBox(height: 12),
//                 _buildSettingsCard([
//                   _buildTapTile(
//                     'Help Center',
//                     'Get help and view tutorials',
//                     Icons.help_center_rounded,
//                     () => _openHelpCenter(),
//                     theme,
//                   ),
//                   _buildDivider(theme),
//                   _buildTapTile(
//                     'Contact Support',
//                     'Chat with our support team',
//                     Icons.chat_rounded,
//                     () => _contactSupport(),
//                     theme,
//                   ),
//                   _buildDivider(theme),
//                   _buildTapTile(
//                     'Rate App',
//                     'Share your experience with others',
//                     Icons.star_rate_rounded,
//                     () => _rateApp(),
//                     theme,
//                   ),
//                 ], theme)
//                     .animate(delay: 1200.ms)
//                     .slideY(begin: 0.3)
//                     .fadeIn(),

//                 const SizedBox(height: 24),

//                 // Account Management
//                 _buildSectionHeader(
//                         'Account', Icons.account_circle_rounded, theme)
//                     .animate(delay: 1300.ms)
//                     .slideX()
//                     .fadeIn(),
//                 const SizedBox(height: 12),
//                 _buildSettingsCard([
//                   _buildTapTile(
//                     'Profile Settings',
//                     'Manage your account details',
//                     Icons.person_rounded,
//                     () => Navigator.pushNamed(context, '/profile'),
//                     theme,
//                   ),
//                   _buildDivider(theme),
//                   _buildTapTile(
//                     'Subscription',
//                     isPremium
//                         ? 'Manage your premium subscription'
//                         : 'Upgrade to premium',
//                     Icons.diamond_rounded,
//                     () => Navigator.pushNamed(context, '/premium'),
//                     theme,
//                     textColor: isPremium ? AppTheme.premiumGold : null,
//                   ),
//                   _buildDivider(theme),
//                   _buildTapTile(
//                     'Sign Out',
//                     'Sign out of your account',
//                     Icons.logout_rounded,
//                     () => _showSignOutDialog(),
//                     theme,
//                     textColor: AppTheme.errorColor,
//                   ),
//                 ], theme)
//                     .animate(delay: 1400.ms)
//                     .slideY(begin: 0.3)
//                     .fadeIn(),

//                 const SizedBox(height: 32),

//                 // App Information
//                 _buildAppInfoCard(theme)
//                     .animate(delay: 1500.ms)
//                     .slideY(begin: 0.3)
//                     .fadeIn(),

//                 const SizedBox(height: 20),
//               ]),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadingScreen(ThemeData theme) {
//     return Scaffold(
//       backgroundColor: theme.colorScheme.surface,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.primary.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: CircularProgressIndicator(
//                 color: theme.colorScheme.primary,
//                 strokeWidth: 3,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'Loading Settings...',
//               style: theme.textTheme.titleMedium?.copyWith(
//                 color: theme.colorScheme.onSurfaceVariant,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSliverAppBar(ThemeData theme) {
//     return SliverAppBar(
//       expandedHeight: 120,
//       floating: true,
//       pinned: false,
//       elevation: 0,
//       backgroundColor: Colors.transparent,
//       surfaceTintColor: Colors.transparent,
//       leading: Container(
//         margin: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: theme.colorScheme.surface.withOpacity(0.9),
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: AppTheme.getElevationShadow(context, 2),
//         ),
//         child: IconButton(
//           onPressed: () {
//             HapticFeedback.lightImpact();
//             Navigator.pop(context);
//           },
//           icon: Icon(
//             Icons.arrow_back_rounded,
//             color: theme.colorScheme.onSurface,
//           ),
//         ),
//       ),
//       flexibleSpace: FlexibleSpaceBar(
//         background: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 theme.colorScheme.primary.withOpacity(0.05),
//                 theme.colorScheme.surface,
//               ],
//             ),
//           ),
//           padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Text(
//                 'Settings',
//                 style: theme.textTheme.headlineLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ).animate().slideX().fadeIn(),
//               const SizedBox(height: 4),
//               Text(
//                 'Customize your AI Vision Pro experience',
//                 style: theme.textTheme.bodyLarge?.copyWith(
//                   color: theme.colorScheme.onSurfaceVariant,
//                 ),
//               ).animate(delay: 200.ms).slideX().fadeIn(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserProfileCard(ThemeData theme) {
//     final user = ref.watch(currentUserProvider);
//     final isPremium = ref.watch(premiumProvider).isPremium;

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             theme.colorScheme.primary.withOpacity(0.1),
//             theme.colorScheme.secondary.withOpacity(0.1),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.2),
//         ),
//         boxShadow: AppTheme.getElevationShadow(context, 2),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               gradient: isPremium
//                   ? AppTheme.premiumGradient
//                   : LinearGradient(
//                       colors: [
//                         theme.colorScheme.primary,
//                         theme.colorScheme.secondary,
//                       ],
//                     ),
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: (isPremium
//                           ? AppTheme.premiumGold
//                           : theme.colorScheme.primary)
//                       .withOpacity(0.3),
//                   blurRadius: 12,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: user?.photoURL != null
//                 ? ClipRRect(
//                     borderRadius: BorderRadius.circular(30),
//                     child: Image.network(
//                       user!.photoURL!,
//                       width: 60,
//                       height: 60,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) => const Icon(
//                         Icons.person_rounded,
//                         color: Colors.white,
//                         size: 30,
//                       ),
//                     ),
//                   )
//                 : const Icon(
//                     Icons.person_rounded,
//                     color: Colors.white,
//                     size: 30,
//                   ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         user?.displayName ?? 'Guest User',
//                         style: theme.textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: theme.colorScheme.onSurface,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     if (isPremium)
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           gradient: AppTheme.premiumGradient,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(
//                               Icons.diamond_rounded,
//                               color: Colors.white,
//                               size: 12,
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               'PRO',
//                               style: theme.textTheme.labelSmall?.copyWith(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ).animate().shimmer(duration: 2000.ms),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   user?.email ?? 'guest@aivisionpro.com',
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color: theme.colorScheme.onSurfaceVariant,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.surface.withOpacity(0.8),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     isPremium ? 'Premium Member' : 'Free User',
//                     style: theme.textTheme.labelMedium?.copyWith(
//                       color: isPremium
//                           ? AppTheme.premiumGold
//                           : theme.colorScheme.primary,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPremiumBanner(ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppTheme.premiumGold,
//             AppTheme.premiumGold.withOpacity(0.8),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppTheme.premiumGold.withOpacity(0.3),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: const Icon(
//               Icons.diamond_rounded,
//               color: Colors.white,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Upgrade to Premium',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Unlock advanced features and unlimited detections',
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: Colors.white.withOpacity(0.9),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               HapticFeedback.lightImpact();
//               Navigator.pushNamed(context, '/premium');
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.white,
//               foregroundColor: AppTheme.premiumGold,
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//             child: Text(
//               'Upgrade',
//               style: theme.textTheme.labelLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
//       child: Row(
//         children: [
//           Container(
//             width: 32,
//             height: 32,
//             decoration: BoxDecoration(
//               color: theme.colorScheme.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               icon,
//               color: theme.colorScheme.primary,
//               size: 18,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Text(
//             title,
//             style: theme.textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: theme.colorScheme.onSurface,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSettingsCard(List<Widget> children, ThemeData theme) {
//     return Container(
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.2),
//         ),
//         boxShadow: AppTheme.getElevationShadow(context, 2),
//       ),
//       child: Column(children: children),
//     );
//   }

//   Widget _buildSwitchTile(
//     String title,
//     String subtitle,
//     IconData icon,
//     bool value,
//     ValueChanged<bool> onChanged,
//     ThemeData theme, {
//     String? badge,
//   }) {
//     return InkWell(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         onChanged(!value);
//       },
//       borderRadius: BorderRadius.circular(20),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Row(
//           children: [
//             Container(
//               width: 44,
//               height: 44,
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 icon,
//                 color: theme.colorScheme.primary,
//                 size: 22,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           title,
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.w600,
//                             color: theme.colorScheme.onSurface,
//                           ),
//                         ),
//                       ),
//                       if (badge != null)
//                         Container(
//                           margin: const EdgeInsets.only(left: 8),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 6, vertical: 2),
//                           decoration: BoxDecoration(
//                             gradient: AppTheme.premiumGradient,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             badge,
//                             style: theme.textTheme.labelSmall?.copyWith(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     subtitle,
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: theme.colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 16),
//             Switch.adaptive(
//               value: value,
//               onChanged: (newValue) {
//                 HapticFeedback.lightImpact();
//                 onChanged(newValue);
//               },
//               activeColor: theme.colorScheme.primary,
//               activeTrackColor: theme.colorScheme.primary.withOpacity(0.3),
//               inactiveThumbColor: theme.colorScheme.outline,
//               inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdownTile(
//     String title,
//     String subtitle,
//     IconData icon,
//     String value,
//     List<String> options,
//     ValueChanged<String?> onChanged,
//     ThemeData theme,
//   ) {
//     return InkWell(
//       onTap: () =>
//           _showDropdownBottomSheet(title, value, options, onChanged, theme),
//       borderRadius: BorderRadius.circular(20),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Row(
//           children: [
//             Container(
//               width: 44,
//               height: 44,
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 icon,
//                 color: theme.colorScheme.primary,
//                 size: 22,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: theme.colorScheme.onSurface,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     subtitle,
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: theme.colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: theme.colorScheme.surfaceContainerHighest
//                           .withOpacity(0.5),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       value,
//                       style: theme.textTheme.labelMedium?.copyWith(
//                         color: theme.colorScheme.primary,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 16),
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               color: theme.colorScheme.onSurfaceVariant,
//               size: 16,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTapTile(
//     String title,
//     String subtitle,
//     IconData icon,
//     VoidCallback onTap,
//     ThemeData theme, {
//     Color? textColor,
//     String? badge,
//   }) {
//     return InkWell(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         onTap();
//       },
//       borderRadius: BorderRadius.circular(20),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Row(
//           children: [
//             Container(
//               width: 44,
//               height: 44,
//               decoration: BoxDecoration(
//                 color:
//                     (textColor ?? theme.colorScheme.primary).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 icon,
//                 color: textColor ?? theme.colorScheme.primary,
//                 size: 22,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           title,
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.w600,
//                             color: textColor ?? theme.colorScheme.onSurface,
//                           ),
//                         ),
//                       ),
//                       if (badge != null)
//                         Container(
//                           margin: const EdgeInsets.only(left: 8),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 6, vertical: 2),
//                           decoration: BoxDecoration(
//                             gradient: AppTheme.premiumGradient,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             badge,
//                             style: theme.textTheme.labelSmall?.copyWith(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     subtitle,
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: theme.colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 16),
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               color: theme.colorScheme.onSurfaceVariant,
//               size: 16,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDivider(ThemeData theme) {
//     return Container(
//       margin: const EdgeInsets.only(left: 76),
//       height: 1,
//       color: theme.colorScheme.outline.withOpacity(0.2),
//     );
//   }

//   Widget _buildAppInfoCard(ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
//             theme.colorScheme.surface,
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.2),
//         ),
//         boxShadow: AppTheme.getElevationShadow(context, 2),
//       ),
//       child: Column(
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   theme.colorScheme.primary,
//                   theme.colorScheme.secondary,
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: theme.colorScheme.primary.withOpacity(0.3),
//                   blurRadius: 20,
//                   offset: const Offset(0, 8),
//                 ),
//               ],
//             ),
//             child: const Icon(
//               Icons.visibility_rounded,
//               size: 40,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'AI Vision Pro',
//             style: theme.textTheme.headlineSmall?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: theme.colorScheme.onSurface,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: theme.colorScheme.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               'Version $_appVersion ($_buildNumber)',
//               style: theme.textTheme.labelLarge?.copyWith(
//                 color: theme.colorScheme.primary,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             'Advanced AI-powered object recognition\nwith real-time detection capabilities',
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: theme.colorScheme.onSurfaceVariant,
//               height: 1.5,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               _buildAppInfoButton(
//                 'What\'s New',
//                 Icons.new_releases_rounded,
//                 () => _showWhatsNewDialog(),
//                 theme,
//               ),
//               _buildAppInfoButton(
//                 'About',
//                 Icons.info_rounded,
//                 () => _showAboutDialog(),
//                 theme,
//               ),
//               _buildAppInfoButton(
//                 'Licenses',
//                 Icons.description_rounded,
//                 () => _showLicensesPage(),
//                 theme,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAppInfoButton(
//     String label,
//     IconData icon,
//     VoidCallback onTap,
//     ThemeData theme,
//   ) {
//     return InkWell(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         onTap();
//       },
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               color: theme.colorScheme.primary,
//               size: 20,
//             ),
//             const SizedBox(height: 6),
//             Text(
//               label,
//               style: theme.textTheme.labelMedium?.copyWith(
//                 color: theme.colorScheme.onSurface,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper Methods
//   void _updateSetting(VoidCallback updateFunction) {
//     setState(updateFunction);
//     _saveSettings();
//   }

//   void _updateTheme(String newTheme) {
//     setState(() => _theme = newTheme);
//     _saveSettings();
//     // Update theme provider if available
//     // ref.read(themeProvider.notifier).setTheme(newTheme);
//   }

//   void _updateLanguage(String newLanguage) {
//     setState(() => _language = newLanguage);
//     _saveSettings();
//     _showSuccessSnackBar('Language updated to $newLanguage');
//   }

//   double _actualCacheSize = 0.0;

//   String _getCacheSize() {
//     return '${_actualCacheSize.toStringAsFixed(1)} MB';
//   }

//   Future<void> _calculateCacheSize() async {
//     try {
//       final tempDir = await getTemporaryDirectory();
//       final cacheDir = await getApplicationCacheDirectory();

//       double totalSize = 0.0;

//       // Calculate temp directory size
//       if (await tempDir.exists()) {
//         totalSize += await _getDirectorySize(tempDir);
//       }

//       // Calculate cache directory size
//       if (await cacheDir.exists()) {
//         totalSize += await _getDirectorySize(cacheDir);
//       }

//       setState(() {
//         _actualCacheSize = totalSize / (1024 * 1024); // Convert to MB
//       });
//     } catch (e) {
//       debugPrint('Failed to calculate cache size: $e');
//       _actualCacheSize = 45.2; // Fallback value
//     }
//   }

//   Future<double> _getDirectorySize(Directory directory) async {
//     double size = 0.0;
//     try {
//       await for (final entity in directory.list(recursive: true)) {
//         if (entity is File) {
//           size += await entity.length();
//         }
//       }
//     } catch (e) {
//       debugPrint('Error calculating directory size: $e');
//     }
//     return size;
//   }

//   void _showErrorSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               Icon(
//                 Icons.error_outline_rounded,
//                 color: Theme.of(context).colorScheme.onError,
//                 size: 20,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   message,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: AppTheme.errorColor,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: const EdgeInsets.all(16),
//         ),
//       );
//     }
//   }

//   void _showSuccessSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               Icon(
//                 Icons.check_circle_rounded,
//                 color: Theme.of(context).colorScheme.onPrimary,
//                 size: 20,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   message,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: AppTheme.successColor,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: const EdgeInsets.all(16),
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   // Dialog and Sheet Methods
//   void _showDropdownBottomSheet(
//     String title,
//     String currentValue,
//     List<String> options,
//     ValueChanged<String?> onChanged,
//     ThemeData theme,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         decoration: BoxDecoration(
//           color: theme.colorScheme.surface,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//           boxShadow: AppTheme.getElevationShadow(context, 12),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Handle
//             Container(
//               width: 40,
//               height: 4,
//               margin: const EdgeInsets.only(top: 12),
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.outline.withOpacity(0.4),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),

//             // Header
//             Padding(
//               padding: const EdgeInsets.all(24),
//               child: Row(
//                 children: [
//                   Text(
//                     'Select $title',
//                     style: theme.textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: theme.colorScheme.onSurface,
//                     ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: Icon(
//                       Icons.close_rounded,
//                       color: theme.colorScheme.onSurfaceVariant,
//                     ),
//                     style: IconButton.styleFrom(
//                       backgroundColor: theme.colorScheme.surfaceContainerHighest
//                           .withOpacity(0.5),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Options
//             ...options.map((option) {
//               final isSelected = option == currentValue;
//               return Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
//                 child: InkWell(
//                   onTap: () {
//                     HapticFeedback.selectionClick();
//                     onChanged(option);
//                     Navigator.pop(context);
//                   },
//                   borderRadius: BorderRadius.circular(16),
//                   child: Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: isSelected
//                           ? theme.colorScheme.primary.withOpacity(0.1)
//                           : theme.colorScheme.surfaceContainerHighest
//                               .withOpacity(0.3),
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(
//                         color: isSelected
//                             ? theme.colorScheme.primary
//                             : theme.colorScheme.outline.withOpacity(0.2),
//                         width: isSelected ? 2 : 1,
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             option,
//                             style: theme.textTheme.titleMedium?.copyWith(
//                               fontWeight: isSelected
//                                   ? FontWeight.bold
//                                   : FontWeight.w500,
//                               color: isSelected
//                                   ? theme.colorScheme.primary
//                                   : theme.colorScheme.onSurface,
//                             ),
//                           ),
//                         ),
//                         if (isSelected)
//                           Icon(
//                             Icons.check_circle_rounded,
//                             color: theme.colorScheme.primary,
//                             size: 24,
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }),

//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showPermissionsDialog() async {
//     final theme = Theme.of(context);

//     // Check current permissions
//     final cameraStatus = await Permission.camera.status;
//     final storageStatus = await Permission.storage.status;
//     final microphoneStatus = await Permission.microphone.status;

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: theme.colorScheme.surface,
//         surfaceTintColor: Colors.transparent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 Icons.security_rounded,
//                 color: theme.colorScheme.primary,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Text(
//               'App Permissions',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Manage permissions for AI Vision Pro',
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 height: 1.5,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color:
//                     theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Current Permissions:',
//                     style: theme.textTheme.titleSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   _buildPermissionStatusItem('Camera', 'Take photos and videos',
//                       Icons.camera_alt_rounded, cameraStatus, theme),
//                   _buildPermissionStatusItem(
//                       'Storage',
//                       'Save detection results',
//                       Icons.storage_rounded,
//                       storageStatus,
//                       theme),
//                   _buildPermissionStatusItem(
//                       'Microphone',
//                       'Voice commands (optional)',
//                       Icons.mic_rounded,
//                       microphoneStatus,
//                       theme),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             style: TextButton.styleFrom(
//               foregroundColor: theme.colorScheme.onSurfaceVariant,
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             ),
//             child: const Text('Close'),
//           ),
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   theme.colorScheme.primary,
//                   theme.colorScheme.primary.withOpacity(0.8),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _requestPermissions();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.transparent,
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 shadowColor: Colors.transparent,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               ),
//               child: const Text(
//                 'Manage Permissions',
//                 style: TextStyle(fontWeight: FontWeight.w600),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPermissionStatusItem(String title, String description,
//       IconData icon, PermissionStatus status, ThemeData theme) {
//     Color statusColor;
//     String statusText;

//     switch (status) {
//       case PermissionStatus.granted:
//         statusColor = AppTheme.successColor;
//         statusText = 'Granted';
//         break;
//       case PermissionStatus.denied:
//         statusColor = AppTheme.errorColor;
//         statusText = 'Denied';
//         break;
//       case PermissionStatus.permanentlyDenied:
//         statusColor = AppTheme.errorColor;
//         statusText = 'Permanently Denied';
//         break;
//       default:
//         statusColor = AppTheme.warningColor;
//         statusText = 'Not Requested';
//     }

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             color: theme.colorScheme.primary,
//             size: 18,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       title,
//                       style: theme.textTheme.bodyMedium?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const Spacer(),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: statusColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: statusColor.withOpacity(0.3)),
//                       ),
//                       child: Text(
//                         statusText,
//                         style: theme.textTheme.labelSmall?.copyWith(
//                           color: statusColor,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Text(
//                   description,
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: theme.colorScheme.onSurfaceVariant,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

// // Add method to request permissions
//   Future<void> _requestPermissions() async {
//     try {
//       final permissions = [
//         Permission.camera,
//         Permission.storage,
//         Permission.microphone,
//       ];

//       final statuses = await permissions.request();

//       // Check if any permissions were denied
//       final deniedPermissions = statuses.entries
//           .where((entry) =>
//               entry.value.isDenied || entry.value.isPermanentlyDenied)
//           .toList();

//       if (deniedPermissions.isEmpty) {
//         _showSuccessSnackBar('All permissions granted successfully!');
//       } else {
//         // Show option to open app settings for permanently denied permissions
//         final permanentlyDenied =
//             deniedPermissions.any((entry) => entry.value.isPermanentlyDenied);

//         if (permanentlyDenied) {
//           _showPermissionSettingsDialog();
//         } else {
//           _showErrorSnackBar('Some permissions were denied. Please try again.');
//         }
//       }
//     } catch (e) {
//       _showErrorSnackBar('Failed to request permissions: $e');
//     }
//   }

//   void _showPermissionSettingsDialog() {
//     final theme = Theme.of(context);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: theme.colorScheme.surface,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Text('Open Settings'),
//         content: Text(
//           'Some permissions are permanently denied. Please enable them in Settings to use all features.',
//           style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               openAppSettings();
//             },
//             child: const Text('Open Settings'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPermissionItem(
//       String title, String description, IconData icon, ThemeData theme) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             color: theme.colorScheme.primary,
//             size: 18,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Text(
//                   description,
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: theme.colorScheme.onSurfaceVariant,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showSignOutDialog() {
//     final theme = Theme.of(context);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: theme.colorScheme.surface,
//         surfaceTintColor: Colors.transparent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: AppTheme.errorColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(
//                 Icons.logout_rounded,
//                 color: AppTheme.errorColor,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Text(
//               'Sign Out',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Are you sure you want to sign out of your account?',
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 height: 1.5,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppTheme.warningColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: AppTheme.warningColor.withOpacity(0.3),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(
//                     Icons.warning_rounded,
//                     color: AppTheme.warningColor,
//                     size: 20,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       'Your detection history and settings will remain saved.',
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: theme.colorScheme.onSurface,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             style: TextButton.styleFrom(
//               foregroundColor: theme.colorScheme.onSurfaceVariant,
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             ),
//             child: const Text('Cancel'),
//           ),
//           Container(
//             decoration: BoxDecoration(
//               color: AppTheme.errorColor,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _performSignOut();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.transparent,
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 shadowColor: Colors.transparent,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               ),
//               child: const Text(
//                 'Sign Out',
//                 style: TextStyle(fontWeight: FontWeight.w600),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showWhatsNewDialog() {
//     final theme = Theme.of(context);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: theme.colorScheme.surface,
//         surfaceTintColor: Colors.transparent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     AppTheme.successColor,
//                     AppTheme.successColor.withOpacity(0.8),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(
//                 Icons.new_releases_rounded,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Text(
//               'What\'s New',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildWhatsNewItem(
//                 'Enhanced AI Detection',
//                 'Improved object recognition accuracy by 25%',
//                 Icons.smart_toy_rounded,
//                 theme,
//               ),
//               _buildWhatsNewItem(
//                 'Real-time Translation',
//                 'Instant translation in 50+ languages',
//                 Icons.translate_rounded,
//                 theme,
//               ),
//               _buildWhatsNewItem(
//                 'Premium Features',
//                 'Advanced analytics and export options',
//                 Icons.diamond_rounded,
//                 theme,
//               ),
//               _buildWhatsNewItem(
//                 'Performance Improvements',
//                 'Faster processing and better battery life',
//                 Icons.speed_rounded,
//                 theme,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   theme.colorScheme.primary,
//                   theme.colorScheme.primary.withOpacity(0.8),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: ElevatedButton(
//               onPressed: () => Navigator.pop(context),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.transparent,
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 shadowColor: Colors.transparent,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//               ),
//               child: const Text(
//                 'Got it!',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWhatsNewItem(
//       String title, String description, IconData icon, ThemeData theme) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               color: theme.colorScheme.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(
//               icon,
//               color: theme.colorScheme.primary,
//               size: 18,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: theme.textTheme.titleSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   description,
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: theme.colorScheme.onSurfaceVariant,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAboutDialog() {
//     showAboutDialog(
//       context: context,
//       applicationName: 'AI Vision Pro',
//       applicationVersion: '$_appVersion+$_buildNumber',
//       applicationIcon: Container(
//         width: 60,
//         height: 60,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Theme.of(context).colorScheme.primary,
//               Theme.of(context).colorScheme.secondary,
//             ],
//           ),
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: const Icon(
//           Icons.visibility_rounded,
//           color: Colors.white,
//           size: 30,
//         ),
//       ),
//       children: [
//         const SizedBox(height: 16),
//         Text(
//           'Advanced AI-powered object recognition app with real-time detection capabilities.',
//           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 height: 1.5,
//               ),
//         ),
//         const SizedBox(height: 16),
//         Text(
//           '© 2024 AI Vision Pro Team. All rights reserved.',
//           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                 color: Theme.of(context).colorScheme.onSurfaceVariant,
//               ),
//         ),
//       ],
//     );
//   }

//   void _showLicensesPage() {
//     showLicensePage(
//       context: context,
//       applicationName: 'AI Vision Pro',
//       applicationVersion: '$_appVersion+$_buildNumber',
//       applicationIcon: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Theme.of(context).colorScheme.primary,
//               Theme.of(context).colorScheme.secondary,
//             ],
//           ),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: const Icon(
//           Icons.visibility_rounded,
//           color: Colors.white,
//           size: 20,
//         ),
//       ),
//     );
//   }

//   // Action Methods
//   void _clearCache() async {
//     final theme = Theme.of(context);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: theme.colorScheme.surface,
//         surfaceTintColor: Colors.transparent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: AppTheme.warningColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(
//                 Icons.cleaning_services_rounded,
//                 color: AppTheme.warningColor,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Text(
//               'Clear Cache',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'This will delete all cached images and temporary files to free up storage space.',
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 height: 1.5,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppTheme.infoColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: AppTheme.infoColor.withOpacity(0.3),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(
//                     Icons.info_rounded,
//                     color: AppTheme.infoColor,
//                     size: 20,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       'Cache size: ${_getCacheSize()}\nYour detection history will not be affected.',
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: theme.colorScheme.onSurface,
//                         height: 1.4,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             style: TextButton.styleFrom(
//               foregroundColor: theme.colorScheme.onSurfaceVariant,
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             ),
//             child: const Text('Cancel'),
//           ),
//           Container(
//             decoration: BoxDecoration(
//               color: AppTheme.warningColor,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _performClearCache();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.transparent,
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 shadowColor: Colors.transparent,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               ),
//               child: const Text(
//                 'Clear Cache',
//                 style: TextStyle(fontWeight: FontWeight.w600),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _performClearCache() async {
//     // Show progress dialog
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: Theme.of(context).colorScheme.surface,
//         surfaceTintColor: Colors.transparent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 color: AppTheme.warningColor.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: const CircularProgressIndicator(
//                 color: AppTheme.warningColor,
//                 strokeWidth: 3,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Clearing cache...',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Please wait while we free up storage space',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Theme.of(context).colorScheme.onSurfaceVariant,
//                   ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );

//     try {
//       // Clear temporary directory
//       final tempDir = await getTemporaryDirectory();
//       if (await tempDir.exists()) {
//         await _clearDirectory(tempDir);
//       }

//       // Clear application cache directory
//       final cacheDir = await getApplicationCacheDirectory();
//       if (await cacheDir.exists()) {
//         await _clearDirectory(cacheDir);
//       }

//       // Clear SharedPreferences cache (optional)
//       // You might want to preserve some settings
//       // final prefs = await SharedPreferences.getInstance();
//       // await prefs.clear();

//       // Recalculate cache size
//       await _calculateCacheSize();

//       if (mounted) {
//         Navigator.pop(context); // Close progress dialog
//         _showSuccessSnackBar(
//             'Cache cleared successfully! Freed up ${_getCacheSize()}');
//       }
//     } catch (e) {
//       if (mounted) {
//         Navigator.pop(context); // Close progress dialog
//         _showErrorSnackBar('Failed to clear cache: $e');
//       }
//     }
//   }

//   Future<void> _clearDirectory(Directory directory) async {
//     try {
//       await for (final entity in directory.list()) {
//         if (entity is File) {
//           await entity.delete();
//         } else if (entity is Directory) {
//           await entity.delete(recursive: true);
//         }
//       }
//     } catch (e) {
//       debugPrint('Error clearing directory: $e');
//     }
//   }

//   void _exportData() {
//     final isPremium = ref.read(premiumProvider).isPremium;

//     if (!isPremium) {
//       Navigator.pushNamed(context, '/premium');
//       return;
//     }

//     final theme = Theme.of(context);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: theme.colorScheme.surface,
//         surfaceTintColor: Colors.transparent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 Icons.download_rounded,
//                 color: theme.colorScheme.primary,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Text(
//               'Export Data',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Choose the format for your detection history export:',
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 height: 1.5,
//               ),
//             ),
//             const SizedBox(height: 20),
//             _buildExportFormatOption(
//                 'PDF Report',
//                 'Complete report with images and analysis',
//                 Icons.picture_as_pdf_rounded,
//                 AppTheme.errorColor,
//                 theme),
//             const SizedBox(height: 12),
//             _buildExportFormatOption(
//                 'CSV Data',
//                 'Spreadsheet format for data analysis',
//                 Icons.table_chart_rounded,
//                 AppTheme.successColor,
//                 theme),
//             const SizedBox(height: 12),
//             _buildExportFormatOption(
//                 'JSON Export',
//                 'Raw data format for developers',
//                 Icons.code_rounded,
//                 AppTheme.infoColor,
//                 theme),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             style: TextButton.styleFrom(
//               foregroundColor: theme.colorScheme.onSurfaceVariant,
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             ),
//             child: const Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildExportFormatOption(String title, String description,
//       IconData icon, Color color, ThemeData theme) {
//     return InkWell(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         Navigator.pop(context);
//         _performExport(title);
//       },
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: color.withOpacity(0.3),
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 36,
//               height: 36,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, color: color, size: 18),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: theme.textTheme.titleSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: theme.colorScheme.onSurface,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     description,
//                     style: theme.textTheme.bodySmall?.copyWith(
//                       color: theme.colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               color: color,
//               size: 16,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _performExport(String format) {
//     // Show progress dialog
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: Theme.of(context).colorScheme.surface,
//         surfaceTintColor: Colors.transparent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: CircularProgressIndicator(
//                 color: Theme.of(context).colorScheme.primary,
//                 strokeWidth: 3,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Exporting $format...',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Preparing your detection history for export',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Theme.of(context).colorScheme.onSurfaceVariant,
//                   ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );

//     // Simulate export process
//     Future.delayed(const Duration(seconds: 3), () {
//       if (mounted) {
//         Navigator.pop(context); // Close progress dialog
//         _showSuccessSnackBar('$format exported successfully!');
//       }
//     });
//   }

//   void _openPrivacyPolicy() async {
//     final url = Uri.parse('https://aivisionpro.com/privacy');
//     try {
//       if (await canLaunchUrl(url)) {
//         await launchUrl(url, mode: LaunchMode.externalApplication);
//       } else {
//         _showErrorSnackBar('Could not open privacy policy');
//       }
//     } catch (e) {
//       _showErrorSnackBar('Failed to open privacy policy: $e');
//     }
//   }

//   void _openHelpCenter() async {
//     final url = Uri.parse('https://help.aivisionpro.com');
//     try {
//       if (await canLaunchUrl(url)) {
//         await launchUrl(url, mode: LaunchMode.externalApplication);
//       } else {
//         _showErrorSnackBar('Could not open help center');
//       }
//     } catch (e) {
//       _showErrorSnackBar('Failed to open help center: $e');
//     }
//   }

//   void _contactSupport() {
//     final theme = Theme.of(context);
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         decoration: BoxDecoration(
//           color: theme.colorScheme.surface,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//           boxShadow: AppTheme.getElevationShadow(context, 12),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Handle
//               Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.outline.withOpacity(0.4),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Header
//               Row(
//                 children: [
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: theme.colorScheme.primary.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Icon(
//                       Icons.support_agent_rounded,
//                       color: theme.colorScheme.primary,
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Text(
//                     'Contact Support',
//                     style: theme.textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 24),

//               // Support Options
//               const SizedBox(height: 16),
//               _buildSupportOption(
//                 'Email Support',
//                 'Send us an email',
//                 Icons.email_rounded,
//                 AppTheme.infoColor,
//                 () => _openEmailSupport(),
//                 theme,
//               ),
//               const SizedBox(height: 16),
//               _buildSupportOption(
//                 'Phone Support',
//                 'Call our support line',
//                 Icons.phone_rounded,
//                 AppTheme.warningColor,
//                 () => _openPhoneSupport(),
//                 theme,
//               ),

//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSupportOption(
//     String title,
//     String subtitle,
//     IconData icon,
//     Color color,
//     VoidCallback onTap,
//     ThemeData theme,
//   ) {
//     return InkWell(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         Navigator.pop(context);
//         onTap();
//       },
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: color.withOpacity(0.3),
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 44,
//               height: 44,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(icon, color: color, size: 22),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: theme.colorScheme.onSurface,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     subtitle,
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: theme.colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               color: color,
//               size: 16,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _openEmailSupport() async {
//     final emailUri = Uri(
//       scheme: 'mailto',
//       path: 'support@aivisionpro.com',
//       query:
//           'subject=AI Vision Pro Support Request&body=Please describe your issue:',
//     );

//     try {
//       if (await canLaunchUrl(emailUri)) {
//         await launchUrl(emailUri);
//       } else {
//         _showErrorSnackBar('Could not open email client');
//       }
//     } catch (e) {
//       _showErrorSnackBar('Failed to open email: $e');
//     }
//   }

//   void _openPhoneSupport() async {
//     final phoneUri = Uri(scheme: 'tel', path: '+1-555-AI-VISION');

//     try {
//       if (await canLaunchUrl(phoneUri)) {
//         await launchUrl(phoneUri);
//       } else {
//         _showErrorSnackBar('Could not make phone call');
//       }
//     } catch (e) {
//       _showErrorSnackBar('Failed to make call: $e');
//     }
//   }

//   void _rateApp() {
//     final theme = Theme.of(context);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: theme.colorScheme.surface,
//         surfaceTintColor: Colors.transparent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     AppTheme.warningColor,
//                     AppTheme.warningColor.withOpacity(0.8),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(
//                 Icons.star_rate_rounded,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Text(
//               'Rate AI Vision Pro',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Love using AI Vision Pro? Your feedback helps us improve and reach more users!',
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 height: 1.5,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(5, (index) {
//                 return const Icon(
//                   Icons.star_rounded,
//                   color: AppTheme.warningColor,
//                   size: 32,
//                 );
//               }),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             style: TextButton.styleFrom(
//               foregroundColor: theme.colorScheme.onSurfaceVariant,
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             ),
//             child: const Text('Maybe Later'),
//           ),
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   AppTheme.warningColor,
//                   AppTheme.warningColor.withOpacity(0.8),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _openAppStore();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.transparent,
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 shadowColor: Colors.transparent,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               ),
//               child: const Text(
//                 'Rate Now',
//                 style: TextStyle(fontWeight: FontWeight.w600),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _openAppStore() async {
//     // iOS App Store URL
//     const iosUrl = 'https://apps.apple.com/app/ai-vision-pro/id123456789';
//     // Google Play Store URL
//     const androidUrl =
//         'https://play.google.com/store/apps/details?id=com.aivisionpro.app';

//     final url = Uri.parse(
//         Theme.of(context).platform == TargetPlatform.iOS ? iosUrl : androidUrl);

//     try {
//       if (await canLaunchUrl(url)) {
//         await launchUrl(url, mode: LaunchMode.externalApplication);
//       } else {
//         _showErrorSnackBar('Could not open app store');
//       }
//     } catch (e) {
//       _showErrorSnackBar('Failed to open app store: $e');
//     }
//   }

//   void _performSignOut() {
//     // Show sign out progress
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: Theme.of(context).colorScheme.surface,
//         surfaceTintColor: Colors.transparent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 color: AppTheme.errorColor.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: const CircularProgressIndicator(
//                 color: AppTheme.errorColor,
//                 strokeWidth: 3,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Signing Out...',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Please wait while we sign you out',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Theme.of(context).colorScheme.onSurfaceVariant,
//                   ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );

//     // Perform sign out
//     Future.delayed(const Duration(seconds: 1), () async {
//       try {
//         await ref.read(authProvider.notifier).signOut();
//         if (mounted) {
//           Navigator.pop(context); // Close progress dialog
//           Navigator.pushNamedAndRemoveUntil(
//             context,
//             '/auth',
//             (route) => false,
//           );
//         }
//       } catch (e) {
//         if (mounted) {
//           Navigator.pop(context); // Close progress dialog
//           _showErrorSnackBar('Failed to sign out: $e');
//         }
//       }
//     });
//   }
// }

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../providers/auth_provider.dart';
import '../providers/premium_provider.dart';
import '../config/app_theme.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;

  // Settings State
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _hapticEnabled = true;
  bool _autoSave = true;
  bool _highQuality = true;
  String _language = 'English';
  String _theme = 'System';

  // App Info
  String _appVersion = '1.0.0';
  String _buildNumber = '1';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSettings();
    _loadAppInfo();
    _calculateCacheSize();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController.forward();
    _fadeController.forward();
  }

  void _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _notificationsEnabled =
              prefs.getBool('notifications_enabled') ?? true;
          _soundEnabled = prefs.getBool('sound_enabled') ?? true;
          _hapticEnabled = prefs.getBool('haptic_enabled') ?? true;
          _autoSave = prefs.getBool('auto_save') ?? true;
          _highQuality = prefs.getBool('high_quality') ?? true;
          _language = prefs.getString('language') ?? 'English';
          _theme = prefs.getString('theme') ?? 'System';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Failed to load settings: $e');
      }
    }
  }

  void _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
          _buildNumber = packageInfo.buildNumber;
        });
      }
    } catch (e) {
      debugPrint('Failed to load app info: $e');
    }
  }

  void _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setBool('notifications_enabled', _notificationsEnabled),
        prefs.setBool('sound_enabled', _soundEnabled),
        prefs.setBool('haptic_enabled', _hapticEnabled),
        prefs.setBool('auto_save', _autoSave),
        prefs.setBool('high_quality', _highQuality),
        prefs.setString('language', _language),
        prefs.setString('theme', _theme),
      ]);
    } catch (e) {
      _showErrorSnackBar('Failed to save settings: $e');
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPremium = ref.watch(premiumProvider).isPremium;

    if (_isLoading) {
      return _buildLoadingScreen(theme);
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(theme),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // User Profile Card
                _buildUserProfileCard(theme).animate().slideX().fadeIn(),

                const SizedBox(height: 24),

                // Premium Banner (if not premium)
                if (!isPremium) ...[
                  _buildPremiumBanner(theme)
                      .animate(delay: 200.ms)
                      .slideY(begin: 0.3)
                      .fadeIn(),
                  const SizedBox(height: 24),
                ],

                // General Settings
                _buildSectionHeader('General', Icons.settings_rounded, theme)
                    .animate(delay: 300.ms)
                    .slideX()
                    .fadeIn(),
                const SizedBox(height: 12),
                _buildSettingsCard([
                  _buildSwitchTile(
                    'Push Notifications',
                    'Receive updates and alerts',
                    Icons.notifications_rounded,
                    _notificationsEnabled,
                    (value) =>
                        _updateSetting(() => _notificationsEnabled = value),
                    theme,
                  ),
                  _buildDivider(theme),
                  _buildSwitchTile(
                    'Sound Effects',
                    'Audio feedback for interactions',
                    Icons.volume_up_rounded,
                    _soundEnabled,
                    (value) => _updateSetting(() => _soundEnabled = value),
                    theme,
                  ),
                  _buildDivider(theme),
                  _buildSwitchTile(
                    'Haptic Feedback',
                    'Vibration for touch interactions',
                    Icons.vibration_rounded,
                    _hapticEnabled,
                    (value) => _updateSetting(() => _hapticEnabled = value),
                    theme,
                  ),
                ], theme)
                    .animate(delay: 400.ms)
                    .slideY(begin: 0.3)
                    .fadeIn(),

                const SizedBox(height: 24),

                // Camera & Detection Settings
                _buildSectionHeader(
                        'Camera & Detection', Icons.camera_alt_rounded, theme)
                    .animate(delay: 500.ms)
                    .slideX()
                    .fadeIn(),
                const SizedBox(height: 12),
                _buildSettingsCard([
                  _buildSwitchTile(
                    'High Quality Images',
                    'Capture in maximum resolution',
                    Icons.hd_rounded,
                    _highQuality,
                    (value) => _updateSetting(() => _highQuality = value),
                    theme,
                    badge: isPremium ? null : 'PRO',
                  ),
                  _buildDivider(theme),
                  _buildSwitchTile(
                    'Auto-save Results',
                    'Automatically save detections',
                    Icons.save_rounded,
                    _autoSave,
                    (value) => _updateSetting(() => _autoSave = value),
                    theme,
                  ),
                  _buildDivider(theme),
                  _buildTapTile(
                    'Camera Permissions',
                    'Manage camera and storage access',
                    Icons.security_rounded,
                    () => _showPermissionsDialog(),
                    theme,
                  ),
                ], theme)
                    .animate(delay: 600.ms)
                    .slideY(begin: 0.3)
                    .fadeIn(),

                const SizedBox(height: 24),

                // Appearance Settings
                _buildSectionHeader('Appearance', Icons.palette_rounded, theme)
                    .animate(delay: 700.ms)
                    .slideX()
                    .fadeIn(),
                const SizedBox(height: 12),
                _buildSettingsCard([
                  _buildDropdownTile(
                    'Theme Mode',
                    'Choose your preferred appearance',
                    Icons.brightness_6_rounded,
                    _theme,
                    ['System', 'Light', 'Dark'],
                    (value) => _updateTheme(value!),
                    theme,
                  ),
                  _buildDivider(theme),
                  _buildDropdownTile(
                    'Language',
                    'Select your preferred language',
                    Icons.language_rounded,
                    _language,
                    [
                      'English',
                      'Spanish',
                      'French',
                      'German',
                      'Chinese',
                      'Japanese'
                    ],
                    (value) => _updateLanguage(value!),
                    theme,
                  ),
                ], theme)
                    .animate(delay: 800.ms)
                    .slideY(begin: 0.3)
                    .fadeIn(),

                const SizedBox(height: 24),

                // Data & Privacy
                _buildSectionHeader(
                        'Data & Privacy', Icons.privacy_tip_rounded, theme)
                    .animate(delay: 900.ms)
                    .slideX()
                    .fadeIn(),
                const SizedBox(height: 12),
                _buildSettingsCard([
                  _buildTapTile(
                    'Clear Cache',
                    'Free up ${_getCacheSize()} of storage space',
                    Icons.cleaning_services_rounded,
                    () => _clearCache(),
                    theme,
                  ),
                  _buildDivider(theme),
                  _buildTapTile(
                    'Export Data',
                    'Download your detection history',
                    Icons.download_rounded,
                    () => _exportData(),
                    theme,
                    badge: isPremium ? null : 'PRO',
                  ),
                  _buildDivider(theme),
                  _buildTapTile(
                    'Privacy Policy',
                    'View our privacy practices',
                    Icons.policy_rounded,
                    () => _openPrivacyPolicy(),
                    theme,
                  ),
                ], theme)
                    .animate(delay: 1000.ms)
                    .slideY(begin: 0.3)
                    .fadeIn(),

                const SizedBox(height: 24),

                // Support & Feedback
                _buildSectionHeader('Support & Feedback',
                        Icons.support_agent_rounded, theme)
                    .animate(delay: 1100.ms)
                    .slideX()
                    .fadeIn(),
                const SizedBox(height: 12),
                _buildSettingsCard([
                  _buildTapTile(
                    'Help Center',
                    'Get help and view tutorials',
                    Icons.help_center_rounded,
                    () => _openHelpCenter(),
                    theme,
                  ),
                  _buildDivider(theme),
                  _buildTapTile(
                    'Contact Support',
                    'Chat with our support team',
                    Icons.chat_rounded,
                    () => _contactSupport(),
                    theme,
                  ),
                  _buildDivider(theme),
                  _buildTapTile(
                    'Rate App',
                    'Share your experience with others',
                    Icons.star_rate_rounded,
                    () => _rateApp(),
                    theme,
                  ),
                ], theme)
                    .animate(delay: 1200.ms)
                    .slideY(begin: 0.3)
                    .fadeIn(),

                const SizedBox(height: 24),

                // Account Management
                _buildSectionHeader(
                        'Account', Icons.account_circle_rounded, theme)
                    .animate(delay: 1300.ms)
                    .slideX()
                    .fadeIn(),
                const SizedBox(height: 12),
                _buildSettingsCard([
                  _buildTapTile(
                    'Profile Settings',
                    'Manage your account details',
                    Icons.person_rounded,
                    () => Navigator.pushNamed(context, '/profile'),
                    theme,
                  ),
                  _buildDivider(theme),
                  _buildTapTile(
                    'Subscription',
                    isPremium
                        ? 'Manage your premium subscription'
                        : 'Upgrade to premium',
                    Icons.diamond_rounded,
                    () => Navigator.pushNamed(context, '/premium'),
                    theme,
                    textColor: isPremium ? AppTheme.premiumGold : null,
                  ),
                  _buildDivider(theme),
                ], theme)
                    .animate(delay: 1400.ms)
                    .slideY(begin: 0.3)
                    .fadeIn(),

                const SizedBox(height: 32),

                // App Information
                _buildAppInfoCard(theme)
                    .animate(delay: 1500.ms)
                    .slideY(begin: 0.3)
                    .fadeIn(),

                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen(ThemeData theme) {
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading Settings...',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      // leading: Container(
      //   margin: const EdgeInsets.all(8),
      //   decoration: BoxDecoration(
      //     color: theme.colorScheme.surface.withOpacity(0.9),
      //     borderRadius: BorderRadius.circular(12),
      //     boxShadow: AppTheme.getElevationShadow(context, 2),
      //   ),
      //   child: IconButton(
      //     onPressed: () {
      //       HapticFeedback.lightImpact();
      //       Navigator.pop(context);
      //     },
      //     icon: Icon(
      //       Icons.arrow_back_rounded,
      //       color: theme.colorScheme.onSurface,
      //     ),
      //   ),
      // ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.05),
                theme.colorScheme.surface,
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Settings',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ).animate().slideX().fadeIn(),
              const SizedBox(height: 4),
              Text(
                'Customize your AI Vision Pro experience',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ).animate(delay: 200.ms).slideX().fadeIn(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileCard(ThemeData theme) {
    final user = ref.watch(currentUserProvider);
    final isPremium = ref.watch(premiumProvider).isPremium;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: AppTheme.getElevationShadow(context, 2),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: isPremium
                  ? AppTheme.premiumGradient
                  : LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isPremium
                          ? AppTheme.premiumGold
                          : theme.colorScheme.primary)
                      .withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: user?.photoURL != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(
                      user!.photoURL!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user?.displayName ?? 'Guest User',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: AppTheme.premiumGradient,
                          borderRadius: BorderRadius.circular(12),
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
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ).animate().shimmer(duration: 2000.ms),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'guest@aivisionpro.com',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPremium ? 'Premium Member' : 'Free User',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isPremium
                          ? AppTheme.premiumGold
                          : theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.premiumGold,
            AppTheme.premiumGold.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.premiumGold.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.diamond_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upgrade to Premium',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Unlock advanced features and unlimited detections',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/premium');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.premiumGold,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              'Upgrade',
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: AppTheme.getElevationShadow(context, 2),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
    ThemeData theme, {
    String? badge,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged(!value);
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (badge != null)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: AppTheme.premiumGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Switch.adaptive(
              value: value,
              onChanged: (newValue) {
                HapticFeedback.lightImpact();
                onChanged(newValue);
              },
              activeColor: theme.colorScheme.primary,
              activeTrackColor: theme.colorScheme.primary.withOpacity(0.3),
              inactiveThumbColor: theme.colorScheme.outline,
              inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: () =>
          _showDropdownBottomSheet(title, value, options, onChanged, theme),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      value,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: theme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTapTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    ThemeData theme, {
    Color? textColor,
    String? badge,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color:
                    (textColor ?? theme.colorScheme.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: textColor ?? theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: textColor ?? theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (badge != null)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: AppTheme.premiumGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: theme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(left: 76),
      height: 1,
      color: theme.colorScheme.outline.withOpacity(0.2),
    );
  }

  Widget _buildAppInfoCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            theme.colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: AppTheme.getElevationShadow(context, 2),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.visibility_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'AI Vision Pro',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Version $_appVersion ($_buildNumber)',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Advanced AI-powered object recognition\nwith real-time detection capabilities',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAppInfoButton(
                'What\'s New',
                Icons.new_releases_rounded,
                () => _showWhatsNewDialog(),
                theme,
              ),
              _buildAppInfoButton(
                'About',
                Icons.info_rounded,
                () => _showAboutDialog(),
                theme,
              ),
              _buildAppInfoButton(
                'Licenses',
                Icons.description_rounded,
                () => _showLicensesPage(),
                theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoButton(
    String label,
    IconData icon,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  void _updateSetting(VoidCallback updateFunction) {
    setState(updateFunction);
    _saveSettings();
  }

  void _updateTheme(String newTheme) {
    setState(() => _theme = newTheme);
    _saveSettings();
    ref.read(themeNotifierProvider.notifier).setThemeMode(newTheme);
  }

  void _updateLanguage(String newLanguage) {
    setState(() => _language = newLanguage);
    _saveSettings();
    _showSuccessSnackBar('Language updated to $newLanguage');
  }

  double _actualCacheSize = 0.0;

  String _getCacheSize() {
    return '${_actualCacheSize.toStringAsFixed(1)} MB';
  }

  Future<void> _calculateCacheSize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = await getApplicationCacheDirectory();

      double totalSize = 0.0;

      if (await tempDir.exists()) {
        totalSize += await _getDirectorySize(tempDir);
      }

      if (await cacheDir.exists()) {
        totalSize += await _getDirectorySize(cacheDir);
      }

      setState(() {
        _actualCacheSize = totalSize / (1024 * 1024);
      });
    } catch (e) {
      debugPrint('Failed to calculate cache size: $e');
      _actualCacheSize = 0.0;
    }
  }

  Future<double> _getDirectorySize(Directory directory) async {
    double size = 0.0;
    try {
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (e) {
      debugPrint('Error calculating directory size: $e');
    }
    return size;
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Theme.of(context).colorScheme.onError,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
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
  }

  // Dialog and Sheet Methods
  void _showDropdownBottomSheet(
    String title,
    String currentValue,
    List<String> options,
    ValueChanged<String?> onChanged,
    ThemeData theme,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: AppTheme.getElevationShadow(context, 12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Text(
                    'Select $title',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...options.map((option) {
              final isSelected = option == currentValue;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onChanged(option);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : theme.colorScheme.surfaceContainerHighest
                              .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showPermissionsDialog() async {
    final theme = Theme.of(context);

    final cameraStatus = await Permission.camera.status;
    final storageStatus = await Permission.storage.status;
    final microphoneStatus = await Permission.microphone.status;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.security_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'App Permissions',
              style: theme.textTheme.titleLarge?.copyWith(
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
              'Manage permissions for AI Vision Pro',
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Permissions:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPermissionStatusItem('Camera', 'Take photos and videos',
                      Icons.camera_alt_rounded, cameraStatus, theme),
                  _buildPermissionStatusItem(
                      'Storage',
                      'Save detection results',
                      Icons.storage_rounded,
                      storageStatus,
                      theme),
                  _buildPermissionStatusItem(
                      'Microphone',
                      'Voice commands (optional)',
                      Icons.mic_rounded,
                      microphoneStatus,
                      theme),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Close'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _requestPermissions();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Manage Permissions',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionStatusItem(String title, String description,
      IconData icon, PermissionStatus status, ThemeData theme) {
    Color statusColor;
    String statusText;

    switch (status) {
      case PermissionStatus.granted:
        statusColor = AppTheme.successColor;
        statusText = 'Granted';
        break;
      case PermissionStatus.denied:
        statusColor = AppTheme.errorColor;
        statusText = 'Denied';
        break;
      case PermissionStatus.permanentlyDenied:
        statusColor = AppTheme.errorColor;
        statusText = 'Permanently Denied';
        break;
      default:
        statusColor = AppTheme.warningColor;
        statusText = 'Not Requested';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        statusText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestPermissions() async {
    try {
      final permissions = [
        Permission.camera,
        Permission.storage,
        Permission.microphone,
      ];

      final statuses = await permissions.request();

      final deniedPermissions = statuses.entries
          .where((entry) =>
              entry.value.isDenied || entry.value.isPermanentlyDenied)
          .toList();

      if (deniedPermissions.isEmpty) {
        _showSuccessSnackBar('All permissions granted successfully!');
      } else {
        final permanentlyDenied =
            deniedPermissions.any((entry) => entry.value.isPermanentlyDenied);

        if (permanentlyDenied) {
          _showPermissionSettingsDialog();
        } else {
          _showErrorSnackBar('Some permissions were denied. Please try again.');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to request permissions: $e');
    }
  }

  void _showPermissionSettingsDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Open Settings'),
        content: Text(
          'Some permissions are permanently denied. Please enable them in Settings to use all features.',
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // void _showSignOutDialog() {
  //   final theme = Theme.of(context);
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: theme.colorScheme.surface,
  //       surfaceTintColor: Colors.transparent,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(20),
  //       ),
  //       title: Row(
  //         children: [
  //           Container(
  //             width: 40,
  //             height: 40,
  //             decoration: BoxDecoration(
  //               color: AppTheme.errorColor.withOpacity(0.1),
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             child: const Icon(
  //               Icons.logout_rounded,
  //               color: AppTheme.errorColor,
  //               size: 20,
  //             ),
  //           ),
  //           const SizedBox(width: 16),
  //           Text(
  //             'Sign Out',
  //             style: theme.textTheme.titleLarge?.copyWith(
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ],
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Are you sure you want to sign out of your account?',
  //             style: theme.textTheme.bodyLarge?.copyWith(
  //               height: 1.5,
  //             ),
  //           ),
  //           const SizedBox(height: 16),
  //           Container(
  //             padding: const EdgeInsets.all(16),
  //             decoration: BoxDecoration(
  //               color: AppTheme.warningColor.withOpacity(0.1),
  //               borderRadius: BorderRadius.circular(12),
  //               border: Border.all(
  //                 color: AppTheme.warningColor.withOpacity(0.3),
  //               ),
  //             ),
  //             child: Row(
  //               children: [
  //                 const Icon(
  //                   Icons.warning_rounded,
  //                   color: AppTheme.warningColor,
  //                   size: 20,
  //                 ),
  //                 const SizedBox(width: 12),
  //                 Expanded(
  //                   child: Text(
  //                     'Your detection history and settings will remain saved.',
  //                     style: theme.textTheme.bodySmall?.copyWith(
  //                       color: theme.colorScheme.onSurface,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           style: TextButton.styleFrom(
  //             foregroundColor: theme.colorScheme.onSurfaceVariant,
  //             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //           ),
  //           child: const Text('Cancel'),
  //         ),
  //         Container(
  //           decoration: BoxDecoration(
  //             color: AppTheme.errorColor,
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: ElevatedButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               _performSignOut();
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.transparent,
  //               foregroundColor: Colors.white,
  //               elevation: 0,
  //               shadowColor: Colors.transparent,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //             ),
  //             child: const Text(
  //               'Sign Out',
  //               style: TextStyle(fontWeight: FontWeight.w600),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showWhatsNewDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.successColor,
                    AppTheme.successColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.new_releases_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'What\'s New',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWhatsNewItem(
                'Enhanced AI Detection',
                'Improved object recognition accuracy by 25%',
                Icons.smart_toy_rounded,
                theme,
              ),
              _buildWhatsNewItem(
                'Real-time Translation',
                'Instant translation in 50+ languages',
                Icons.translate_rounded,
                theme,
              ),
              _buildWhatsNewItem(
                'Premium Features',
                'Advanced analytics and export options',
                Icons.diamond_rounded,
                theme,
              ),
              _buildWhatsNewItem(
                'Performance Improvements',
                'Faster processing and better battery life',
                Icons.speed_rounded,
                theme,
              ),
            ],
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Got it!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsNewItem(
      String title, String description, IconData icon, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'AI Vision Pro',
      applicationVersion: '$_appVersion+$_buildNumber',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(
          Icons.visibility_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: [
        const SizedBox(height: 16),
        Text(
          'Advanced AI-powered object recognition app with real-time detection capabilities.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          '© 2024 AI Vision Pro Team. All rights reserved.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  void _showLicensesPage() {
    showLicensePage(
      context: context,
      applicationName: 'AI Vision Pro',
      applicationVersion: '$_appVersion+$_buildNumber',
      applicationIcon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.visibility_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  // Action Methods
  void _clearCache() async {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.cleaning_services_rounded,
                color: AppTheme.warningColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Clear Cache',
              style: theme.textTheme.titleLarge?.copyWith(
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
              'This will delete all cached images and temporary files to free up storage space.',
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.infoColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_rounded,
                    color: AppTheme.infoColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Cache size: ${_getCacheSize()}\nYour detection history will not be affected.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        height: 1.4,
                      ),
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
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Cancel'),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.warningColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _performClearCache();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Clear Cache',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performClearCache() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                color: AppTheme.warningColor,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Clearing cache...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we free up storage space',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = await getApplicationCacheDirectory();

      if (await tempDir.exists()) {
        await _clearDirectory(tempDir);
      }

      if (await cacheDir.exists()) {
        await _clearDirectory(cacheDir);
      }

      await _calculateCacheSize();

      if (mounted) {
        Navigator.pop(context);
        _showSuccessSnackBar(
            'Cache cleared successfully! Freed up ${_getCacheSize()}');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorSnackBar('Failed to clear cache: $e');
      }
    }
  }

  Future<void> _clearDirectory(Directory directory) async {
    try {
      await for (final entity in directory.list()) {
        if (entity is File) {
          await entity.delete();
        } else if (entity is Directory) {
          await entity.delete(recursive: true);
        }
      }
    } catch (e) {
      debugPrint('Error clearing directory: $e');
    }
  }

  void _exportData() {
    final isPremium = ref.read(premiumProvider).isPremium;

    if (!isPremium) {
      Navigator.pushNamed(context, '/premium');
      return;
    }

    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.download_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Export Data',
              style: theme.textTheme.titleLarge?.copyWith(
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
              'Choose the format for your detection history export:',
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _buildExportFormatOption(
                'PDF Report',
                'Complete report with images and analysis',
                Icons.picture_as_pdf_rounded,
                AppTheme.errorColor,
                theme),
            const SizedBox(height: 12),
            _buildExportFormatOption(
                'CSV Data',
                'Spreadsheet format for data analysis',
                Icons.table_chart_rounded,
                AppTheme.successColor,
                theme),
            const SizedBox(height: 12),
            _buildExportFormatOption(
                'JSON Export',
                'Raw data format for developers',
                Icons.code_rounded,
                AppTheme.infoColor,
                theme),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildExportFormatOption(String title, String description,
      IconData icon, Color color, ThemeData theme) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        _performExport(title);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _performExport(String format) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Exporting $format...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Preparing your detection history for export',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context);
        _showSuccessSnackBar('$format exported successfully!');
      }
    });
  }

  void _openPrivacyPolicy() async {
    final url = Uri.parse('https://aivisionpro.com/privacy');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not open privacy policy');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to open privacy policy: $e');
    }
  }

  void _openHelpCenter() async {
    final url = Uri.parse('https://help.aivisionpro.com');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not open help center');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to open help center: $e');
    }
  }

  void _contactSupport() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: AppTheme.getElevationShadow(context, 12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.support_agent_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Contact Support',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 16),
              _buildSupportOption(
                'Email Support',
                'Send us an email',
                Icons.email_rounded,
                AppTheme.infoColor,
                () => _openEmailSupport(),
                theme,
              ),
              const SizedBox(height: 16),
              _buildSupportOption(
                'Phone Support',
                'Call our support line',
                Icons.phone_rounded,
                AppTheme.warningColor,
                () => _openPhoneSupport(),
                theme,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportOption(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _openEmailSupport() async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: 'support@aivisionpro.com',
      query:
          'subject=AI Vision Pro Support Request&body=Please describe your issue:',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showErrorSnackBar('Could not open email client');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to open email: $e');
    }
  }

  void _openPhoneSupport() async {
    final phoneUri = Uri(scheme: 'tel', path: '+1-555-AI-VISION');

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorSnackBar('Could not make phone call');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to make call: $e');
    }
  }

  void _rateApp() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.warningColor,
                    AppTheme.warningColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.star_rate_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Rate AI Vision Pro',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Love using AI Vision Pro? Your feedback helps us improve and reach more users!',
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return const Icon(
                  Icons.star_rounded,
                  color: AppTheme.warningColor,
                  size: 32,
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Maybe Later'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.warningColor,
                  AppTheme.warningColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _openAppStore();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Rate Now',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openAppStore() async {
    const iosUrl = 'https://apps.apple.com/app/ai-vision-pro/id123456789';
    const androidUrl =
        'https://play.google.com/store/apps/details?id=com.aivisionpro.app';

    final url = Uri.parse(
        Theme.of(context).platform == TargetPlatform.iOS ? iosUrl : androidUrl);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not open app store');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to open app store: $e');
    }
  }

  // void _performSignOut() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: Theme.of(context).colorScheme.surface,
  //       surfaceTintColor: Colors.transparent,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(20),
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Container(
  //             width: 60,
  //             height: 60,
  //             decoration: BoxDecoration(
  //               color: AppTheme.errorColor.withOpacity(0.1),
  //               shape: BoxShape.circle,
  //             ),
  //             child: const CircularProgressIndicator(
  //               color: AppTheme.errorColor,
  //               strokeWidth: 3,
  //             ),
  //           ),
  //           const SizedBox(height: 20),
  //           Text(
  //             'Signing Out...',
  //             style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             'Please wait while we sign you out',
  //             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  //                   color: Theme.of(context).colorScheme.onSurfaceVariant,
  //                 ),
  //             textAlign: TextAlign.center,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );

  //   Future.delayed(const Duration(seconds: 1), () async {
  //     try {
  //       await ref.read(authProvider.notifier).signOut();
  //       if (mounted) {
  //         Navigator.pop(context);
  //         Navigator.pushNamedAndRemoveUntil(
  //           context,
  //           '/auth',
  //           (route) => false,
  //         );
  //       }
  //     } catch (e) {
  //       if (mounted) {
  //         Navigator.pop(context);
  //         _showErrorSnackBar('Failed to sign out: $e');
  //       }
  //     }
  //   });
  // }
}
