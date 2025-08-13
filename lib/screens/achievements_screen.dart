// screens/achievements_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../models/achievement.dart';
import '../providers/analytics_provider.dart';
import '../providers/premium_provider.dart';
import '../config/app_theme.dart';
import '../widgets/achievement_banner.dart';
import '../widgets/ad_widgets.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  String _selectedCategory = 'all';

  final List<String> _categories = [
    'all',
    'detection',
    'exploration',
    'social',
    'challenges'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final analyticsState = ref.watch(analyticsProvider);
    final isPremium = ref.watch(premiumProvider).isPremium;

    final achievements = _getAllAchievements(analyticsState);
    final filteredAchievements = _selectedCategory == 'all'
        ? achievements
        : achievements.where((a) => a.category == _selectedCategory).toList();

    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final totalCount = achievements.length;
    final completionPercentage = (unlockedCount / totalCount * 100).round();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(
              theme, unlockedCount, totalCount, completionPercentage),

          // Banner ad for non-premium users
          if (!isPremium)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: const AdBanner(
                  placement: 'achievements_top',
                  adSize: AdSize.mediumRectangle,
                ),
              ).animate().slideY(begin: 0.3).fadeIn(),
            ),

          _buildProgressSection(
              theme, unlockedCount, totalCount, completionPercentage),
          _buildCategoryFilters(theme),

          // Native ad in content feed
          if (!isPremium && filteredAchievements.length > 6)
            SliverToBoxAdapter(
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: const NativeAdWidget(placement: 'achievements_feed'),
              ),
            ),

          _buildAchievementsGrid(filteredAchievements, theme),

          // Another banner ad at bottom
          if (!isPremium)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: const AdBanner(placement: 'achievements_bottom'),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(
      ThemeData theme, int unlockedCount, int totalCount, int percentage) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        icon: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppTheme.getElevationShadow(context, 2),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.onSurface,
            size: 18,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showAchievementTips();
            },
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.getElevationShadow(context, 2),
              ),
              child: Icon(
                Icons.help_outline_rounded,
                color: theme.colorScheme.onSurface,
                size: 20,
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
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.secondary.withOpacity(0.1),
                theme.colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      AnimatedBuilder(
                        animation: _sparkleController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _sparkleController.value * 2 * 3.14159,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.premiumGold,
                                    AppTheme.premiumGold.withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppTheme.premiumGold.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.emoji_events_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Achievements',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ).animate().slideX().fadeIn(),
                            const SizedBox(height: 4),
                            Text(
                              '$unlockedCount of $totalCount unlocked ($percentage%)',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ).animate(delay: 200.ms).slideX().fadeIn(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(
      ThemeData theme, int unlockedCount, int totalCount, int percentage) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Overall Progress',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$percentage%',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Progress bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: unlockedCount / totalCount,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                _buildProgressItem(
                  'Unlocked',
                  unlockedCount.toString(),
                  Icons.check_circle_rounded,
                  AppTheme.successColor,
                  theme,
                ),
                const SizedBox(width: 24),
                _buildProgressItem(
                  'Remaining',
                  (totalCount - unlockedCount).toString(),
                  Icons.lock_rounded,
                  theme.colorScheme.onSurfaceVariant,
                  theme,
                ),
                const SizedBox(width: 24),
                _buildProgressItem(
                  'Total XP',
                  '${unlockedCount * 50}',
                  Icons.star_rounded,
                  AppTheme.warningColor,
                  theme,
                ),
              ],
            ),
          ],
        ),
      ).animate().slideY(begin: 0.3).fadeIn(),
    );
  }

  Widget _buildProgressItem(
      String label, String value, IconData icon, Color color, ThemeData theme) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = category == _selectedCategory;

            return Container(
              margin: const EdgeInsets.only(right: 12),
              child: FilterChip(
                label: Text(
                  _getCategoryLabel(category),
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedCategory = category);
                },
                selectedColor: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: isSelected ? 2 : 0,
                pressElevation: 4,
              ),
            );
          },
        ),
      ).animate(delay: 600.ms).slideX().fadeIn(),
    );
  }

  Widget _buildAchievementsGrid(
      List<ExtendedAchievement> achievements, ThemeData theme) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final achievement = achievements[index];
            return _buildAchievementCard(achievement, theme, index);
          },
          childCount: achievements.length,
        ),
      ),
    );
  }

  Widget _buildAchievementCard(
      ExtendedAchievement achievement, ThemeData theme, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showAchievementDetail(achievement);
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: achievement.isUnlocked
                ? achievement.color.withOpacity(0.3)
                : theme.colorScheme.outline.withOpacity(0.2),
            width: achievement.isUnlocked ? 2 : 1,
          ),
          boxShadow: achievement.isUnlocked
              ? [
                  BoxShadow(
                    color: achievement.color.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : AppTheme.getElevationShadow(context, 2),
        ),
        child: Stack(
          children: [
            // Background pattern for unlocked achievements
            if (achievement.isUnlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        achievement.color.withOpacity(0.05),
                        achievement.color.withOpacity(0.02),
                      ],
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon and status
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: achievement.isUnlocked
                              ? achievement.color
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: achievement.isUnlocked
                              ? [
                                  BoxShadow(
                                    color: achievement.color.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          achievement.icon,
                          color: achievement.isUnlocked
                              ? Colors.white
                              : theme.colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      if (achievement.isUnlocked)
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (_pulseController.value * 0.2),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: AppTheme.successColor,
                                size: 24,
                              ),
                            );
                          },
                        )
                      else
                        Icon(
                          Icons.lock_rounded,
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.5),
                          size: 20,
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    achievement.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: achievement.isUnlocked
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    achievement.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: achievement.isUnlocked
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Progress or reward
                  if (achievement.progress != null && !achievement.isUnlocked)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Progress',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${achievement.progress}/${achievement.target}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: (achievement.progress! / achievement.target!),
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(achievement.color),
                        ),
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: achievement.isUnlocked
                            ? AppTheme.successColor.withOpacity(0.1)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        achievement.isUnlocked
                            ? '+${achievement.xp} XP'
                            : '${achievement.xp} XP',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: achievement.isUnlocked
                              ? AppTheme.successColor
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: 100 * index))
          .slideY(begin: 0.3)
          .fadeIn(),
    );
  }

  // Helper methods
  String _getCategoryLabel(String category) {
    switch (category) {
      case 'all':
        return 'All';
      case 'detection':
        return 'Detection';
      case 'exploration':
        return 'Explorer';
      case 'social':
        return 'Social';
      case 'challenges':
        return 'Challenges';
      default:
        return category;
    }
  }

  List<ExtendedAchievement> _getAllAchievements(AnalyticsState analyticsState) {
    return [
      // Detection Achievements
      ExtendedAchievement(
        title: 'First Scan',
        description: 'Complete your first object detection',
        icon: Icons.camera_alt_rounded,
        isUnlocked: analyticsState.totalDetections > 0,
        color: AppTheme.successColor,
        category: 'detection',
        xp: 50,
        progress: analyticsState.totalDetections > 0 ? 1 : 0,
        target: 1,
      ),
      ExtendedAchievement(
        title: 'Scanner',
        description: 'Scan 10 different objects',
        icon: Icons.qr_code_scanner_rounded,
        isUnlocked: analyticsState.totalDetections >= 10,
        color: AppTheme.primaryColor,
        category: 'detection',
        xp: 100,
        progress: analyticsState.totalDetections.clamp(0, 10),
        target: 10,
      ),
      ExtendedAchievement(
        title: 'Explorer',
        description: 'Scan 100 different objects',
        icon: Icons.explore_rounded,
        isUnlocked: analyticsState.totalDetections >= 100,
        color: AppTheme.secondaryColor,
        category: 'detection',
        xp: 500,
        progress: analyticsState.totalDetections.clamp(0, 100),
        target: 100,
      ),
      ExtendedAchievement(
        title: 'Master Detective',
        description: 'Scan 1000 different objects',
        icon: Icons.search_rounded,
        isUnlocked: analyticsState.totalDetections >= 1000,
        color: AppTheme.premiumGold,
        category: 'detection',
        xp: 2000,
        progress: analyticsState.totalDetections.clamp(0, 1000),
        target: 1000,
      ),

      // Accuracy Achievements
      ExtendedAchievement(
        title: 'Sharp Eye',
        description: 'Achieve 80%+ average accuracy',
        icon: Icons.visibility_rounded,
        isUnlocked: analyticsState.averageConfidence >= 0.8,
        color: AppTheme.warningColor,
        category: 'detection',
        xp: 200,
      ),
      ExtendedAchievement(
        title: 'Accuracy Master',
        description: 'Achieve 90%+ average accuracy',
        icon: Icons.trending_up_rounded,
        isUnlocked: analyticsState.averageConfidence >= 0.9,
        color: AppTheme.primaryColor,
        category: 'detection',
        xp: 500,
      ),
      ExtendedAchievement(
        title: 'Perfect Vision',
        description: 'Achieve 95%+ average accuracy',
        icon: Icons.remove_red_eye_rounded,
        isUnlocked: analyticsState.averageConfidence >= 0.95,
        color: AppTheme.premiumGold,
        category: 'detection',
        xp: 1000,
      ),

      // Exploration Achievements
      ExtendedAchievement(
        title: 'Animal Lover',
        description: 'Scan 20 different animals',
        icon: Icons.pets_rounded,
        isUnlocked: false, // Would need to track animal detections
        color: Colors.brown,
        category: 'exploration',
        xp: 300,
        progress: 5, // Mock progress
        target: 20,
      ),
      ExtendedAchievement(
        title: 'Plant Expert',
        description: 'Scan 15 different plants',
        icon: Icons.local_florist_rounded,
        isUnlocked: false,
        color: Colors.green,
        category: 'exploration',
        xp: 250,
        progress: 3,
        target: 15,
      ),
      ExtendedAchievement(
        title: 'Food Critic',
        description: 'Scan 30 different food items',
        icon: Icons.restaurant_rounded,
        isUnlocked: false,
        color: Colors.orange,
        category: 'exploration',
        xp: 400,
        progress: 12,
        target: 30,
      ),

      // Challenge Achievements
      ExtendedAchievement(
        title: 'Daily Challenger',
        description: 'Complete 7 daily challenges',
        icon: Icons.star_rounded,
        isUnlocked: false,
        color: AppTheme.warningColor,
        category: 'challenges',
        xp: 350,
        progress: 2,
        target: 7,
      ),
      ExtendedAchievement(
        title: 'Streak Master',
        description: 'Maintain a 30-day challenge streak',
        icon: Icons.local_fire_department_rounded,
        isUnlocked: false,
        color: Colors.deepOrange,
        category: 'challenges',
        xp: 1500,
        progress: 5,
        target: 30,
      ),

      // Social Achievements
      ExtendedAchievement(
        title: 'Sharer',
        description: 'Share your first detection',
        icon: Icons.share_rounded,
        isUnlocked: false,
        color: Colors.blue,
        category: 'social',
        xp: 100,
      ),
      ExtendedAchievement(
        title: 'Collector',
        description: 'Save 50 detections to favorites',
        icon: Icons.favorite_rounded,
        isUnlocked: false,
        color: Colors.pink,
        category: 'social',
        xp: 300,
        progress: 8,
        target: 50,
      ),
    ];
  }

  void _showAchievementDetail(ExtendedAchievement achievement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Achievement icon and status
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: achievement.isUnlocked
                            ? achievement.color
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: achievement.isUnlocked
                            ? [
                                BoxShadow(
                                  color: achievement.color.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        achievement.icon,
                        color: achievement.isUnlocked
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title and status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          achievement.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(width: 8),
                        if (achievement.isUnlocked)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppTheme.successColor,
                            size: 24,
                          )
                        else
                          Icon(
                            Icons.lock_rounded,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Description
                    Text(
                      achievement.description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                    ),

                    const SizedBox(height: 32),

                    // Progress section
                    if (achievement.progress != null &&
                        !achievement.isUnlocked) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progress',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                Text(
                                  '${achievement.progress}/${achievement.target}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: achievement.color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value:
                                  (achievement.progress! / achievement.target!),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  achievement.color),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${((achievement.progress! / achievement.target!) * 100).round()}% Complete',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Reward section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: achievement.isUnlocked
                              ? [
                                  AppTheme.successColor.withOpacity(0.1),
                                  AppTheme.successColor.withOpacity(0.05),
                                ]
                              : [
                                  achievement.color.withOpacity(0.1),
                                  achievement.color.withOpacity(0.05),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: achievement.isUnlocked
                              ? AppTheme.successColor.withOpacity(0.3)
                              : achievement.color.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: achievement.isUnlocked
                                  ? AppTheme.successColor.withOpacity(0.2)
                                  : achievement.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.star_rounded,
                              color: achievement.isUnlocked
                                  ? AppTheme.successColor
                                  : achievement.color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reward',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${achievement.xp} XP',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: achievement.isUnlocked
                                            ? AppTheme.successColor
                                            : achievement.color,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (achievement.isUnlocked)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Earned',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Action buttons
                    if (!achievement.isUnlocked) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/camera');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: achievement.color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Start Scanning',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          achievement.isUnlocked ? 'Close' : 'Maybe Later',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
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
      ),
    );
  }

  void _showAchievementTips() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.lightbulb_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Achievement Tips',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTipItem(
              'Use the camera regularly to unlock detection achievements',
              Icons.camera_alt_rounded,
              Theme.of(context),
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              'Complete daily challenges for bonus XP and special achievements',
              Icons.star_rounded,
              Theme.of(context),
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              'Try scanning different categories of objects to unlock exploration achievements',
              Icons.explore_rounded,
              Theme.of(context),
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              'Share your detections and save favorites for social achievements',
              Icons.share_rounded,
              Theme.of(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got It',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip, IconData icon, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            tip,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// Extended Achievement model with additional properties
class ExtendedAchievement extends Achievement {
  final String category;
  final int xp;
  final int? progress;
  final int? target;

  ExtendedAchievement({
    required super.title,
    required super.description,
    required super.icon,
    required super.isUnlocked,
    required super.color,
    required this.category,
    required this.xp,
    this.progress,
    this.target,
  });
}
