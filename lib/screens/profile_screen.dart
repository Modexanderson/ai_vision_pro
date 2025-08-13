// screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/detection_history.dart';
import '../providers/auth_provider.dart';
import '../providers/premium_provider.dart';
import '../providers/analytics_provider.dart';
import '../providers/history_provider.dart';
import '../providers/favorites_provider.dart';
import '../config/app_theme.dart';
import '../utils/haptic_feedback.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _shimmerController;

  bool _isEditing = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fadeController.forward();
    _slideController.forward();
  }

  void _loadUserData() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _nameController.text = user.displayName ?? 'AI Explorer';
      _emailController.text = user.email ?? '';
      _bioController.text = 'Exploring the world through AI vision';
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _shimmerController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isPremium = ref.watch(premiumProvider).isPremium;
    final analyticsState = ref.watch(analyticsProvider);
    final historyList = ref.watch(historyProvider);
    final favoritesList = ref.watch(favoritesProvider);
    final theme = Theme.of(context);

    final isGuest = !authState.isAuthenticated;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(isGuest, isPremium, theme),
          _buildProfileContent(
            isGuest,
            isPremium,
            analyticsState,
            historyList,
            favoritesList,
            theme,
          ),
          _buildAdPreferencesSection(isPremium, theme),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(bool isGuest, bool isPremium, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      // leading: Container(
      //   margin: const EdgeInsets.all(8),
      //   decoration: BoxDecoration(
      //     color: theme.colorScheme.surface.withOpacity(0.9),
      //     borderRadius: BorderRadius.circular(10),
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
      actions: [
        if (!isGuest)
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isEditing
                  ? AppTheme.successColor.withOpacity(0.9)
                  : theme.colorScheme.primary.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
              boxShadow: AppTheme.getElevationShadow(context, 2),
            ),
            child: TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                if (_isEditing) {
                  _saveProfile();
                } else {
                  setState(() => _isEditing = true);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                _isEditing ? 'Save' : 'Edit',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8),
                theme.colorScheme.secondary.withOpacity(0.6),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                _buildProfileAvatar(isGuest, theme),
                const SizedBox(height: 20),
                _buildProfileInfo(isGuest, isPremium, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(bool isGuest, ThemeData theme) {
    final user = ref.watch(currentUserProvider);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: theme.colorScheme.surface,
            backgroundImage:
                user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            child: user?.photoURL == null
                ? Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.8),
                          theme.colorScheme.secondary.withOpacity(0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
        ),
        if (!isGuest && _isEditing)
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _changeProfilePicture();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.secondary,
                      theme.colorScheme.tertiary,
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: AppTheme.getElevationShadow(context, 4),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    ).animate().scale(delay: 200.ms).then().shimmer(duration: 2000.ms);
  }

  Widget _buildProfileInfo(bool isGuest, bool isPremium, ThemeData theme) {
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        if (isGuest) ...[
          Text(
            'Welcome, Guest!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().slideY(begin: 0.3).fadeIn(delay: 400.ms),
          const SizedBox(height: 8),
          Text(
            'Sign in to unlock all features',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ).animate().slideY(begin: 0.3).fadeIn(delay: 600.ms),
        ] else ...[
          Text(
            user?.displayName ?? 'AI Explorer',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().slideY(begin: 0.3).fadeIn(delay: 400.ms),
          const SizedBox(height: 6),
          Text(
            user?.email ?? '',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ).animate().slideY(begin: 0.3).fadeIn(delay: 500.ms),
          if (isPremium) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppTheme.premiumGradient,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.premiumGold.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.diamond_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'PREMIUM',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ).animate().shimmer(duration: 2000.ms).fadeIn(delay: 600.ms),
          ],
        ],
      ],
    );
  }

  Widget _buildAdPreferencesSection(bool isPremium, ThemeData theme) {
    if (isPremium) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.successColor.withOpacity(0.1),
                AppTheme.successColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.successColor.withOpacity(0.3),
            ),
            boxShadow: AppTheme.getElevationShadow(context, 2),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.successColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Ad-Free Experience Active',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'You\'re enjoying an ad-free experience with your premium subscription. No more interruptions while using AI Vision Pro!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ).animate(delay: 1200.ms).slideY(begin: 0.3).fadeIn(),
      );
    }

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: AppTheme.getElevationShadow(context, 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.ads_click_rounded,
                    color: AppTheme.warningColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Ad Preferences',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.warningColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.warningColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ads help keep AI Vision Pro free for everyone. Upgrade to Premium to remove all ads and unlock advanced features.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/premium');
                },
                icon: const Icon(
                  Icons.block_rounded,
                  size: 18,
                ),
                label: Text(
                  'Remove Ads - Upgrade to Premium',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate(delay: 1200.ms).slideY(begin: 0.3).fadeIn(),
    );
  }

  Widget _buildProfileContent(
    bool isGuest,
    bool isPremium,
    AnalyticsState analyticsState,
    List<dynamic> historyList,
    List<dynamic> favoritesList,
    ThemeData theme,
  ) {
    return SliverList(
      delegate: SliverChildListDelegate([
        const SizedBox(height: 20),
        if (isGuest) ...[
          _buildGuestPrompt(theme),
        ] else ...[
          if (_isEditing) _buildEditForm(theme),
          _buildStatsOverview(
              analyticsState, historyList, favoritesList, theme),
          _buildAchievementsSection(analyticsState, isPremium, theme),
          _buildActivityInsights(historyList, theme),
        ],
        _buildQuickActions(isGuest, isPremium, theme),
        _buildAccountSection(isGuest, theme),
      ]),
    );
  }

  Widget _buildGuestPrompt(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
          ),
          boxShadow: AppTheme.getElevationShadow(context, 8),
        ),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: AppTheme.getElevationShadow(context, 4),
              ),
              child: const Icon(
                Icons.account_circle_rounded,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Unlock Your AI Journey',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Create an account to save your detection history, earn achievements, access premium features, and track your AI exploration progress.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/auth');
                },
                icon: const Icon(Icons.login_rounded, size: 20),
                label: Text(
                  'Sign Up / Sign In',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate().slideY(begin: 0.3).fadeIn(),
    );
  }

  Widget _buildEditForm(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: AppTheme.getElevationShadow(context, 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  Icons.edit_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Edit Profile',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: 'Display Name',
              hintText: 'Enter your display name',
              prefixIcon: Icon(
                Icons.person_outline_rounded,
                color: theme.colorScheme.primary,
              ),
              labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              filled: true,
              fillColor:
                  theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _bioController,
            maxLines: 3,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: 'Bio',
              hintText: 'Tell us about yourself',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              filled: true,
              fillColor:
                  theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3).fadeIn();
  }

  Widget _buildStatsOverview(
    AnalyticsState analyticsState,
    List<dynamic> historyList,
    List<dynamic> favoritesList,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: AppTheme.getElevationShadow(context, 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  Icons.analytics_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Your Statistics',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 0.9,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard(
                'Total Scans',
                '${historyList.length}',
                Icons.camera_alt_rounded,
                theme.colorScheme.primary,
                theme,
              ),
              _buildStatCard(
                'Objects Found',
                '${analyticsState.totalDetections}',
                Icons.category_rounded,
                AppTheme.successColor,
                theme,
              ),
              _buildStatCard(
                'Avg Accuracy',
                '${(analyticsState.averageConfidence * 100).toInt()}%',
                Icons.trending_up_rounded,
                AppTheme.warningColor,
                theme,
              ),
              _buildStatCard(
                'Favorites',
                '${favoritesList.length}',
                Icons.favorite_rounded,
                AppTheme.errorColor,
                theme,
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 200.ms).slideY(begin: 0.3).fadeIn();
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(
    AnalyticsState analyticsState,
    bool isPremium,
    ThemeData theme,
  ) {
    final achievements = _getAchievements(analyticsState, isPremium);
    final unlockedCount =
        achievements.where((a) => a['unlocked'] as bool).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: AppTheme.getElevationShadow(context, 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: AppTheme.warningColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Achievements',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.2),
                      theme.colorScheme.secondary.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '$unlockedCount/${achievements.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return _buildAchievementCard(
                achievement['title'] as String,
                achievement['description'] as String,
                achievement['icon'] as IconData,
                achievement['unlocked'] as bool,
                achievement['color'] as Color,
                theme,
              );
            },
          ),
        ],
      ),
    ).animate(delay: 400.ms).slideY(begin: 0.3).fadeIn();
  }

  Widget _buildAchievementCard(
    String title,
    String description,
    IconData icon,
    bool isUnlocked,
    Color color,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showAchievementDetail(
            title, description, icon, isUnlocked, color, theme);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
                  ],
                )
              : LinearGradient(
                  colors: [
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? color.withOpacity(0.3)
                : theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? color.withOpacity(0.2)
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isUnlocked
                    ? color
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isUnlocked
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isUnlocked)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityInsights(List<dynamic> historyList, ThemeData theme) {
    if (historyList.isEmpty) return const SizedBox.shrink();

    // Calculate insights
    final recentActivity = historyList
        .where((item) => DateTime.now().difference(item.timestamp).inDays <= 7)
        .length;

    final todayActivity = historyList
        .where((item) => DateTime.now().difference(item.timestamp).inDays == 0)
        .length;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: AppTheme.getElevationShadow(context, 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: AppTheme.infoColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Recent Activity',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInsightItem(
                  'Today',
                  '$todayActivity scans',
                  Icons.today_rounded,
                  AppTheme.infoColor,
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInsightItem(
                  'This Week',
                  '$recentActivity scans',
                  Icons.calendar_today_rounded,
                  AppTheme.successColor,
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 600.ms).slideY(begin: 0.3).fadeIn();
  }

  Widget _buildInsightItem(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isGuest, bool isPremium, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: AppTheme.getElevationShadow(context, 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  Icons.flash_on_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Quick Actions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!isGuest && !isPremium) ...[
            _buildActionTile(
              'Upgrade to Premium',
              'Unlock advanced AI features and analytics',
              Icons.diamond_rounded,
              AppTheme.premiumGold,
              () {
                HapticFeedback.lightImpact();
                Navigator.pushNamed(context, '/premium');
              },
              theme,
            ),
            _buildDivider(theme),
          ],
          _buildActionTile(
            'Settings & Preferences',
            'Customize your app experience',
            Icons.settings_rounded,
            AppTheme.infoColor,
            () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/settings');
            },
            theme,
          ),
          _buildDivider(theme),
          _buildActionTile(
            'Help & Support',
            'Get help and contact our support team',
            Icons.help_center_rounded,
            AppTheme.successColor,
            () {
              HapticFeedback.lightImpact();
              _openSupport();
            },
            theme,
          ),
          _buildDivider(theme),
          _buildActionTile(
            'Share App',
            'Tell your friends about AI Vision Pro',
            Icons.share_rounded,
            theme.colorScheme.secondary,
            () {
              HapticFeedback.lightImpact();
              _shareApp();
            },
            theme,
          ),
          _buildDivider(theme),
          _buildActionTile(
            'Rate Us',
            'Rate our app in the store',
            Icons.star_rate_rounded,
            AppTheme.warningColor,
            () {
              HapticFeedback.lightImpact();
              _rateApp();
            },
            theme,
          ),
        ],
      ),
    ).animate(delay: 800.ms).slideY(begin: 0.3).fadeIn();
  }

  Widget _buildAccountSection(bool isGuest, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: AppTheme.getElevationShadow(context, 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.security_rounded,
                  color: theme.colorScheme.tertiary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Account & Privacy',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isGuest) ...[
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/auth');
                },
                icon: const Icon(Icons.login_rounded, size: 20),
                label: Text(
                  'Sign In to Your Account',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ] else ...[
            _buildActionTile(
              'Privacy Settings',
              'Manage your data and privacy preferences',
              Icons.privacy_tip_rounded,
              AppTheme.warningColor,
              () {
                HapticFeedback.lightImpact();
                _openPrivacySettings();
              },
              theme,
            ),
            _buildDivider(theme),
            _buildActionTile(
              'Export My Data',
              'Download all your account data',
              Icons.download_rounded,
              AppTheme.infoColor,
              () {
                HapticFeedback.lightImpact();
                _exportUserData();
              },
              theme,
            ),
            _buildDivider(theme),
            _buildActionTile(
              'Delete Account',
              'Permanently delete your account and data',
              Icons.delete_forever_rounded,
              AppTheme.errorColor,
              () {
                HapticFeedback.lightImpact();
                _showDeleteAccountDialog();
              },
              theme,
            ),
            _buildDivider(theme),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showSignOutDialog();
                },
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppTheme.errorColor,
                  size: 20,
                ),
                label: Text(
                  'Sign Out',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.errorColor, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate(delay: 1000.ms).slideY(begin: 0.3).fadeIn();
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color, size: 24),
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
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.3,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 24,
      thickness: 1,
      color: theme.colorScheme.outline.withOpacity(0.2),
    );
  }

  // Helper Methods
  List<Map<String, dynamic>> _getAchievements(
    AnalyticsState analyticsState,
    bool isPremium,
  ) {
    final historyList = ref.watch(historyProvider);
    final favoritesList = ref.watch(favoritesProvider);

    return [
      {
        'title': 'First Scan',
        'description': 'Complete your first detection',
        'icon': Icons.camera_alt_rounded,
        'unlocked': historyList.isNotEmpty, // Check if any scans exist
        'color': AppTheme.successColor,
      },
      {
        'title': 'Explorer',
        'description': 'Scan 50 different objects',
        'icon': Icons.explore_rounded,
        'unlocked': historyList.length >= 50, // Based on scan count
        'color': AppTheme.infoColor,
      },
      {
        'title': 'AI Expert',
        'description': 'Achieve 90%+ average accuracy',
        'icon': Icons.psychology_rounded,
        'unlocked': _calculateAverageAccuracy(historyList) >= 0.9,
        'color': AppTheme.secondaryColor,
      },
      {
        'title': 'Premium User',
        'description': 'Upgrade to premium features',
        'icon': Icons.diamond_rounded,
        'unlocked': isPremium,
        'color': AppTheme.premiumGold,
      },
      {
        'title': 'Dedication',
        'description': 'Use the app for 7 days straight',
        'icon': Icons.local_fire_department_rounded,
        'unlocked': _checkDailyStreak(historyList) >= 7,
        'color': AppTheme.errorColor,
      },
      {
        'title': 'Collector',
        'description': 'Save 25 items to favorites',
        'icon': Icons.collections_rounded,
        'unlocked': favoritesList.length >= 25,
        'color': AppTheme.warningColor,
      },
    ];
  }

// Helper method to calculate average accuracy from history
  double _calculateAverageAccuracy(List<DetectionHistory> history) {
    if (history.isEmpty) return 0.0;

    double totalAccuracy = 0.0;
    int count = 0;

    for (final item in history) {
      totalAccuracy += item.averageConfidence;
      count++;
    }

    return count > 0 ? totalAccuracy / count : 0.0;
  }

// Helper method to check daily streak
  int _checkDailyStreak(List<DetectionHistory> history) {
    if (history.isEmpty) return 0;

    // Sort by date (most recent first)
    final sortedHistory = List<DetectionHistory>.from(history)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    int streak = 0;
    DateTime currentDate = DateTime.now();

    // Check each day going backwards
    for (int i = 0; i < 30; i++) {
      // Check up to 30 days
      final checkDate = currentDate.subtract(Duration(days: i));
      final hasActivityOnDate = sortedHistory.any((item) =>
          item.timestamp.year == checkDate.year &&
          item.timestamp.month == checkDate.month &&
          item.timestamp.day == checkDate.day);

      if (hasActivityOnDate) {
        streak++;
      } else if (i > 0) {
        // Don't break on first day if no activity today
        break;
      }
    }

    return streak;
  }

  // Action Methods
  void _changeProfilePicture() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.getElevationShadow(context, 8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Change Profile Picture',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildImageSourceButton(
                          'Camera',
                          Icons.camera_alt_rounded,
                          () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.camera);
                          },
                          Theme.of(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildImageSourceButton(
                          'Gallery',
                          Icons.photo_library_rounded,
                          () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.gallery);
                          },
                          Theme.of(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
    ThemeData theme,
  ) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image != null) {
        // Show loading indicator
        _showLoadingDialog('Updating profile picture...');

        // Simulate upload delay
        await Future.delayed(const Duration(seconds: 2));

        Navigator.pop(context); // Close loading dialog

        _showSuccessSnackBar('Profile picture updated successfully!');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog if open
      _showErrorSnackBar('Failed to update picture: $e');
    }
  }

  void _saveProfile() {
    _showLoadingDialog('Saving profile...');

    // Simulate save delay
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context); // Close loading dialog
      setState(() => _isEditing = false);
      _showSuccessSnackBar('Profile updated successfully!');
    });
  }

  void _showAchievementDetail(
    String title,
    String description,
    IconData icon,
    bool isUnlocked,
    Color color,
    ThemeData theme,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? AppTheme.successColor.withOpacity(0.1)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUnlocked
                      ? AppTheme.successColor.withOpacity(0.3)
                      : theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isUnlocked
                        ? Icons.check_circle_rounded
                        : Icons.lock_rounded,
                    color: isUnlocked
                        ? AppTheme.successColor
                        : theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isUnlocked ? 'Achievement Unlocked!' : 'Achievement Locked',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isUnlocked
                          ? AppTheme.successColor
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text(
              'Close',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(String message) {
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
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
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
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
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
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
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
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _openSupport() async {
    const url = 'mailto:support@aivisionpro.com?subject=Support Request';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        _showErrorSnackBar(
          'Could not open email client. Please contact support@aivisionpro.com',
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to open support: $e');
    }
  }

  void _shareApp() async {
    try {
      await Share.share(
        'Check out AI Vision Pro - the amazing AI-powered object detection app! '
        'Download it now: https://play.google.com/store/apps/details?id=com.aivisionpro.app',
        subject: 'AI Vision Pro - Amazing AI Object Detection',
      );
    } catch (e) {
      _showErrorSnackBar('Could not share app: $e');
    }
  }

  void _rateApp() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.aivisionpro.app';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not open app store');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to open app store: $e');
    }
  }

  void _openPrivacySettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            boxShadow: AppTheme.getElevationShadow(context, 12),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.privacy_tip_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Privacy Settings',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPrivacyOption(
                        'Analytics Collection',
                        'Allow us to collect anonymous usage data to improve the app',
                        Icons.analytics_rounded,
                        true,
                        (value) {
                          HapticFeedback.lightImpact();
                          _showSuccessSnackBar(value
                              ? 'Analytics collection enabled'
                              : 'Analytics collection disabled');
                        },
                      ),
                      _buildDivider(Theme.of(context)),
                      _buildPrivacyOption(
                        'Crash Reporting',
                        'Automatically send crash reports to help fix bugs',
                        Icons.bug_report_rounded,
                        true,
                        (value) {
                          HapticFeedback.lightImpact();
                          _showSuccessSnackBar(value
                              ? 'Crash reporting enabled'
                              : 'Crash reporting disabled');
                        },
                      ),
                      _buildDivider(Theme.of(context)),
                      _buildPrivacyOption(
                        'Image Storage',
                        'Store processed images locally for faster access',
                        Icons.storage_rounded,
                        true,
                        (value) {
                          HapticFeedback.lightImpact();
                          _showSuccessSnackBar(value
                              ? 'Local image storage enabled'
                              : 'Local image storage disabled');
                        },
                      ),
                      _buildDivider(Theme.of(context)),
                      _buildPrivacyOption(
                        'Cloud Backup',
                        'Backup your data to cloud for device sync',
                        Icons.cloud_upload_rounded,
                        false,
                        (value) {
                          HapticFeedback.lightImpact();
                          _showSuccessSnackBar(value
                              ? 'Cloud backup enabled'
                              : 'Cloud backup disabled');
                        },
                      ),
                      _buildDivider(Theme.of(context)),

                      // Privacy Policy Link
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.infoColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.article_rounded,
                            color: AppTheme.infoColor,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          'Privacy Policy',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        subtitle: Text(
                          'Read our complete privacy policy',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _openPrivacyPolicy();
                        },
                      ),
                      _buildDivider(Theme.of(context)),

                      // Terms of Service Link
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.description_rounded,
                            color: AppTheme.successColor,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          'Terms of Service',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        subtitle: Text(
                          'Read our terms and conditions',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _openTermsOfService();
                        },
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyOption(
    String title,
    String subtitle,
    IconData icon,
    bool initialValue,
    Function(bool) onChanged,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool value = initialValue;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
          trailing: Switch(
            value: value,
            onChanged: (newValue) {
              setState(() => value = newValue);
              onChanged(newValue);
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }

  void _openPrivacyPolicy() async {
    const url = 'https://aivisionpro.com/privacy';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        _showErrorSnackBar('Could not open privacy policy');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to open privacy policy: $e');
    }
  }

  void _openTermsOfService() async {
    const url = 'https://aivisionpro.com/terms';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        _showErrorSnackBar('Could not open terms of service');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to open terms of service: $e');
    }
  }

  void _exportUserData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.download_rounded,
                color: AppTheme.infoColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Export My Data',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        content: Text(
          'We will prepare a complete export of your account data including:\n\n'
          '• Detection history\n'
          '• Favorites and collections\n'
          '• Achievement progress\n'
          '• App preferences\n\n'
          'This may take a few minutes. You will receive an email when ready.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
                _performDataExport();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Export Data',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performDataExport() {
    _showLoadingDialog(
        'Preparing your data export...\nThis may take a few minutes');

    // Simulate export process
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      _showSuccessSnackBar(
        'Data export initiated! You will receive an email when ready.',
      );
    });
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: AppTheme.errorColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Account',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.errorColor,
                  ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete your account?\n\n'
          'This action will:\n'
          '• Delete all your detection history\n'
          '• Remove all saved favorites\n'
          '• Clear all achievement progress\n'
          '• Cancel any premium subscriptions\n\n'
          'This action cannot be undone.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              _confirmAccountDeletion();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Delete Account',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmAccountDeletion() {
    final TextEditingController confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          'Final Confirmation',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.errorColor,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type "DELETE" to confirm account deletion:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Type DELETE here',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.errorColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.errorColor,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedbackUtil.lightImpact();
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (confirmController.text.trim().toUpperCase() == 'DELETE') {
                HapticFeedback.heavyImpact();
                Navigator.pop(context);
                _performAccountDeletion();
              } else {
                _showErrorSnackBar('Please type "DELETE" to confirm');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Confirm Delete',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _performAccountDeletion() {
    _showLoadingDialog('Deleting your account...\nPlease wait');

    // Simulate deletion process
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/auth',
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Account deleted successfully',
                  style: TextStyle(
                    color: Colors.white,
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
    });
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Sign Out',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out?\n\n'
          'Your data will remain safe and you can sign back in anytime.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.errorColor,
                  AppTheme.errorColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
                _performSignOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performSignOut() async {
    _showLoadingDialog('Signing out...');

    try {
      // Sign out from auth provider
      await ref.read(authProvider.notifier).signOut();

      // Clear any cached data
      ref.read(historyProvider.notifier).clearHistory();

      // Clear favorites if the provider has this method
      try {
        ref.read(favoritesProvider.notifier).clearFavorites();
        // ignore: empty_catches
      } catch (e) {
        // Favorites provider might not have clearFavorites method
      }

      // Navigate to auth screen
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/auth',
        (route) => false,
      );

      _showSuccessSnackBar('Successfully signed out');
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar('Failed to sign out: $e');
    }
  }
}
