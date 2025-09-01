// screens/history_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../models/detection_history.dart';
import '../providers/history_provider.dart';
import '../providers/premium_provider.dart';
import '../providers/analytics_provider.dart';
import '../config/app_theme.dart';
import '../widgets/ad_widgets.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _searchController;

  String _sortBy = 'Recent';
  String _filterBy = 'All';
  bool _isSearching = false;
  final TextEditingController _searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    _searchTextController.dispose();
    super.dispose();
  }

  List<DetectionHistory> _getFilteredHistory(List<DetectionHistory> history) {
    var filtered = List<DetectionHistory>.from(history);

    // Apply search filter
    if (_searchTextController.text.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.detectedObjects.any((object) => object
            .toLowerCase()
            .contains(_searchTextController.text.toLowerCase()));
      }).toList();
    }

    // Apply category filter
    if (_filterBy != 'All') {
      filtered = filtered.where((item) {
        return item.detectedObjects.any(
            (object) => _categorizeObject(object) == _filterBy.toLowerCase());
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'Recent':
        filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case 'Oldest':
        filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case 'Confidence':
        filtered
            .sort((a, b) => b.averageConfidence.compareTo(a.averageConfidence));
        break;
    }

    return filtered;
  }

  String _categorizeObject(String label) {
    final lowercaseLabel = label.toLowerCase();
    if (lowercaseLabel.contains('person') ||
        lowercaseLabel.contains('people')) {
      return 'people';
    } else if (lowercaseLabel.contains('car') ||
        lowercaseLabel.contains('vehicle')) {
      return 'vehicles';
    } else if (lowercaseLabel.contains('animal') ||
        lowercaseLabel.contains('dog') ||
        lowercaseLabel.contains('cat')) {
      return 'animals';
    }
    return 'objects';
  }

  @override
  Widget build(BuildContext context) {
    final historyList = ref.watch(historyProvider);
    final isPremium = ref.watch(premiumProvider).isPremium;
    final analyticsState = ref.watch(analyticsProvider);
    final filteredHistory = _getFilteredHistory(historyList);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(historyList.length, theme),
          if (historyList.isNotEmpty) ...[
            _buildStatsOverview(analyticsState, historyList, theme),
            _buildFilterSortBar(theme),
          ],
          _buildHistoryContent(filteredHistory, isPremium, theme),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(int totalCount, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.secondary.withOpacity(0.05),
                theme.colorScheme.surface,
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isSearching ? 'Search History' : 'Detection History',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ).animate().slideX().fadeIn(),
                    const SizedBox(height: 8),
                    Text(
                      '$totalCount ${totalCount == 1 ? 'detection' : 'detections'} saved',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ).animate(delay: 200.ms).slideX().fadeIn(),
                  ],
                ),
              ),
              _buildAppBarActions(theme)
                  .animate(delay: 400.ms)
                  .slideX()
                  .fadeIn(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarActions(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isSearching) ...[
          Container(
            width: 200,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: TextField(
              controller: _searchTextController,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search detections...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              onChanged: (value) {
                HapticFeedback.selectionClick();
                setState(() {});
              },
            ),
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Icons.close_rounded,
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isSearching = false;
                _searchTextController.clear();
              });
              _searchController.reverse();
            },
            theme: theme,
          ),
        ] else ...[
          _buildActionButton(
            icon: Icons.search_rounded,
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => _isSearching = true);
              _searchController.forward();
            },
            theme: theme,
          ),
          const SizedBox(width: 8),
          _buildPopupMenu(theme),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required ThemeData theme,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        onPressed: onPressed,
        splashRadius: 22,
      ),
    );
  }

  Widget _buildPopupMenu(ThemeData theme) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: PopupMenuButton<String>(
        onSelected: _handleMenuAction,
        icon: Icon(
          Icons.more_vert_rounded,
          color: theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'export',
            child: Row(
              children: [
                Icon(
                  Icons.download_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Export History',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'clear_all',
            child: Row(
              children: [
                Icon(
                  Icons.delete_sweep_rounded,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Clear All',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(AnalyticsState analyticsState,
      List<DetectionHistory> history, ThemeData theme) {
    final totalObjects =
        history.fold<int>(0, (sum, item) => sum + item.detectedObjects.length);
    final avgConfidence = history.isEmpty
        ? 0.0
        : history.fold<double>(0, (sum, item) => sum + item.averageConfidence) /
            history.length;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
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
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total\nScans',
                  '${history.length}',
                  Icons.history_rounded,
                  theme,
                ),
              ),
              _buildDivider(theme),
              Expanded(
                child: _buildStatItem(
                  'Objects\nFound',
                  '$totalObjects',
                  Icons.category_rounded,
                  theme,
                ),
              ),
              _buildDivider(theme),
              Expanded(
                child: _buildStatItem(
                  'Avg\nAccuracy',
                  '${(avgConfidence * 100).toInt()}%',
                  Icons.trending_up_rounded,
                  theme,
                ),
              ),
            ],
          ),
        ),
      ).animate().slideY(begin: 0.3).fadeIn(),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Container(
      width: 1,
      height: 50,
      color: theme.colorScheme.outline.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSortBar(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: AppTheme.getElevationShadow(context, 1),
        ),
        child: Row(
          children: [
            // Filter Dropdown
            Expanded(
              child: _buildDropdown(
                value: _filterBy,
                hint: 'Filter',
                items: ['All', 'People', 'Objects', 'Animals', 'Vehicles'],
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  setState(() => _filterBy = value!);
                },
                icon: Icons.filter_list_rounded,
                theme: theme,
              ),
            ),

            const SizedBox(width: 16),

            // Sort Dropdown
            Expanded(
              child: _buildDropdown(
                value: _sortBy,
                hint: 'Sort',
                items: ['Recent', 'Oldest', 'Confidence'],
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  setState(() => _sortBy = value!);
                },
                icon: Icons.sort_rounded,
                theme: theme,
              ),
            ),
          ],
        ),
      ).animate(delay: 200.ms).slideY(begin: 0.3).fadeIn(),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                hint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          isExpanded: true,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(item),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildHistoryContent(
      List<DetectionHistory> filteredHistory, bool isPremium, ThemeData theme) {
    if (filteredHistory.isEmpty) {
      return _buildEmptyState(theme);
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = filteredHistory[index];

          // Banner ad every 5 items for non-premium users
          if (!isPremium && index > 0 && index % 5 == 0) {
            return Column(
              children: [
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: const AdBanner(placement: 'history'),
                ),
                _buildHistoryItem(item, index, isPremium, theme),
              ],
            );
          }

          return _buildHistoryItem(item, index, isPremium, theme);
        },
        childCount: filteredHistory.length,
      ),
    );
  }

  Widget _buildHistoryItem(
      DetectionHistory item, int index, bool isPremium, ThemeData theme) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, index == 0 ? 20 : 8, 20, 8),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                _showHistoryDetails(item, theme);
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildImageThumbnail(item, theme),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.detectedObjects.join(', '),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatTimestamp(item.timestamp),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildStatChip(
                                '${(item.averageConfidence * 100).toInt()}%',
                                _getConfidenceColor(item.averageConfidence),
                                theme,
                              ),
                              const SizedBox(width: 8),
                              _buildStatChip(
                                '${item.detectedObjects.length} objects',
                                theme.colorScheme.onSurfaceVariant,
                                theme,
                                isSecondary: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildItemMenu(item, isPremium, theme),
                  ],
                ),
              ),
            ),

            // Ad-supported export for free users
            if (!isPremium)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: RewardedAdButton(
                  featureName: 'Export Data',
                  onRewardEarned: () => _exportSingleItem(item, theme),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.warningColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.download_rounded,
                          size: 18,
                          color: AppTheme.warningColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Export (Watch Ad)',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppTheme.warningColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ).animate(delay: (index * 50).ms).slideX().fadeIn(),
    );
  }

  Widget _buildStatChip(String text, Color color, ThemeData theme,
      {bool isSecondary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSecondary
            ? theme.colorScheme.surfaceContainerHighest
            : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSecondary
              ? theme.colorScheme.outline.withOpacity(0.3)
              : color.withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: isSecondary ? theme.colorScheme.onSurfaceVariant : color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(DetectionHistory item, ThemeData theme) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: File(item.imagePath).existsSync()
            ? Image.file(
                File(item.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderThumbnail(theme);
                },
              )
            : _buildPlaceholderThumbnail(theme),
      ),
    );
  }

  Widget _buildPlaceholderThumbnail(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_rounded,
        color: theme.colorScheme.onSurfaceVariant,
        size: 28,
      ),
    );
  }

  Widget _buildItemMenu(
      DetectionHistory item, bool isPremium, ThemeData theme) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: PopupMenuButton<String>(
        onSelected: (value) => _handleItemAction(value, item, theme),
        icon: Icon(
          Icons.more_vert_rounded,
          color: theme.colorScheme.onSurfaceVariant,
          size: 18,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'view',
            child: Row(
              children: [
                Icon(
                  Icons.visibility_rounded,
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  'View Details',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                Icon(
                  Icons.share_rounded,
                  color: theme.colorScheme.secondary,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  'Share',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (isPremium)
            PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  const Icon(
                    Icons.download_rounded,
                    color: AppTheme.successColor,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Export',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete_rounded,
                  color: theme.colorScheme.error,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  'Delete',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24), // Reduced padding
          child: SingleChildScrollView(
            // Added scrollability
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Use minimum space needed
              children: [
                Container(
                  width: 100, // Reduced size
                  height: 100, // Reduced size
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _searchTextController.text.isNotEmpty
                        ? Icons.search_off_rounded
                        : Icons.history_rounded,
                    size: 48, // Reduced icon size
                    color: theme.colorScheme.primary.withOpacity(0.7),
                  ),
                ).animate().scale(),
                const SizedBox(height: 20), // Reduced spacing
                Text(
                  _searchTextController.text.isNotEmpty
                      ? 'No results found'
                      : 'No detection history',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ).animate(delay: 200.ms).slideY(begin: 0.3).fadeIn(),
                const SizedBox(height: 8), // Reduced spacing
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _searchTextController.text.isNotEmpty
                        ? 'Try a different search term or filter'
                        : 'Your scan results will appear here after you start detecting objects',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      // Changed to bodyMedium
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4, // Reduced line height
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3, // Limit lines to prevent overflow
                    overflow: TextOverflow.ellipsis,
                  ),
                ).animate(delay: 400.ms).slideY(begin: 0.3).fadeIn(),
                if (_searchTextController.text.isEmpty) ...[
                  const SizedBox(height: 24), // Reduced spacing
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(14), // Slightly smaller radius
                      boxShadow: AppTheme.getElevationShadow(context, 4),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushNamed(context, '/camera');
                      },
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 20, // Specified icon size
                      ),
                      label: const Text(
                        'Start Scanning',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16, // Specified font size
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28, // Reduced padding
                          vertical: 14, // Reduced padding
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ).animate(delay: 600.ms).scale(),
                  const SizedBox(height: 16), // Add bottom spacing for safety
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Methods
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(timestamp);
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppTheme.successColor;
    if (confidence >= 0.6) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  // Action Methods
  void _handleMenuAction(String action) {
    HapticFeedback.lightImpact();
    switch (action) {
      case 'export':
        _exportHistory();
        break;
      case 'clear_all':
        _showClearAllDialog();
        break;
    }
  }

  void _handleItemAction(
      String action, DetectionHistory item, ThemeData theme) {
    HapticFeedback.lightImpact();
    switch (action) {
      case 'view':
        _showHistoryDetails(item, theme);
        break;
      case 'share':
        _shareHistoryItem(item);
        break;
      case 'export':
        _exportSingleItem(item, theme);
        break;
      case 'delete':
        _deleteHistoryItem(item, theme);
        break;
    }
  }

  void _showHistoryDetails(DetectionHistory item, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: AppTheme.getElevationShadow(context, 8),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detection Details',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTimestamp(item.timestamp),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: theme.colorScheme.onSurfaceVariant,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      Container(
                        width: double.infinity,
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: File(item.imagePath).existsSync()
                              ? Image.file(
                                  File(item.imagePath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: theme
                                          .colorScheme.surfaceContainerHighest,
                                      child: Icon(
                                        Icons.image_rounded,
                                        size: 64,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.image_rounded,
                                    size: 64,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Detected Objects
                      Text(
                        'Detected Objects',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: item.detectedObjects.map((object) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              object,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Statistics
                      Text(
                        'Detection Statistics',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildStatRow(
                              'Objects Found',
                              '${item.detectedObjects.length}',
                              theme,
                            ),
                            const SizedBox(height: 16),
                            _buildStatRow(
                              'Average Confidence',
                              '${(item.averageConfidence * 100).toInt()}%',
                              theme,
                              color:
                                  _getConfidenceColor(item.averageConfidence),
                            ),
                            const SizedBox(height: 16),
                            _buildStatRow(
                              'Detection Mode',
                              item.mode?.displayName ?? 'Object Detection',
                              theme,
                            ),
                            const SizedBox(height: 16),
                            _buildStatRow(
                              'Processing Time',
                              '${(item.averageConfidence * 3).toStringAsFixed(1)}s',
                              theme,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _shareHistoryItem(item);
                              },
                              icon: Icon(
                                Icons.share_rounded,
                                color: theme.colorScheme.primary,
                              ),
                              label: Text(
                                'Share',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: theme.colorScheme.primary,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.secondary,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, '/camera');
                                },
                                icon: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Scan Again',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildStatRow(String label, String value, ThemeData theme,
      {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  void _shareHistoryItem(DetectionHistory item) async {
    final objectsText = item.detectedObjects.join(', ');
    final timestamp = DateFormat('MMM d, y - h:mm a').format(item.timestamp);

    await Share.share(
      'AI Vision Detection Results\n\n'
      'Objects: $objectsText\n'
      'Confidence: ${(item.averageConfidence * 100).toInt()}%\n'
      'Date: $timestamp\n\n'
      'Powered by AI Vision Pro',
      subject: 'Detection Results',
    );
  }

  void _exportSingleItem(DetectionHistory item, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildExportSheet(item, theme),
    );
  }

  Widget _buildExportSheet(DetectionHistory item, ThemeData theme) {
    return Container(
      height: 380, // Increased height to accommodate content
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: AppTheme.getElevationShadow(context, 8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important: Use minimum space needed
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Export Detection',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          // Export Options - Using Flexible instead of Expanded
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildExportOption(
                    icon: Icons.picture_as_pdf_rounded,
                    color: AppTheme.errorColor,
                    title: 'Export as PDF',
                    subtitle: 'Detailed report with image and analysis',
                    onTap: () => _performExport(item, 'PDF', theme),
                    theme: theme,
                  ),
                  const SizedBox(height: 12),
                  _buildExportOption(
                    icon: Icons.table_chart_rounded,
                    color: AppTheme.successColor,
                    title: 'Export as CSV',
                    subtitle: 'Spreadsheet format for data analysis',
                    onTap: () => _performExport(item, 'CSV', theme),
                    theme: theme,
                  ),
                  const SizedBox(height: 12),
                  _buildExportOption(
                    icon: Icons.code_rounded,
                    color: AppTheme.primaryColor,
                    title: 'Export as JSON',
                    subtitle: 'Raw data format for developers',
                    onTap: () => _performExport(item, 'JSON', theme),
                    theme: theme,
                  ),
                  const SizedBox(height: 20), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
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
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  void _performExport(DetectionHistory item, String format, ThemeData theme) {
    Navigator.pop(context);

    // Show export progress
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Exporting as $format...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );

    // Simulate export process
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Detection exported as $format successfully',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
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
          action: SnackBarAction(
            label: 'Share',
            textColor: theme.colorScheme.onPrimary,
            onPressed: () => _shareHistoryItem(item),
          ),
        ),
      );
    });
  }

  void _deleteHistoryItem(DetectionHistory item, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Detection',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this detection result? This action cannot be undone.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.error,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(historyProvider.notifier).removeItem(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: theme.colorScheme.onPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Detection deleted successfully',
                          style: TextStyle(
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
                  ),
                );
              },
              child: Text(
                'Delete',
                style: TextStyle(
                  color: theme.colorScheme.onError,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    final historyCount = ref.read(historyProvider).length;
    final theme = Theme.of(context);

    if (historyCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.info_rounded,
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                'No history to clear',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Clear All History',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to delete all $historyCount detection${historyCount == 1 ? '' : 's'}? This action cannot be undone.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.error,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(historyProvider.notifier).clearHistory();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: theme.colorScheme.onPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'All $historyCount detection${historyCount == 1 ? '' : 's'} cleared',
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
                  ),
                );
              },
              child: Text(
                'Clear All',
                style: TextStyle(
                  color: theme.colorScheme.onError,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _exportHistory() {
    final historyList = ref.read(historyProvider);
    final theme = Theme.of(context);

    if (historyList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.info_rounded,
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                'No history to export',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 400,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: AppTheme.getElevationShadow(context, 8),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Export All History (${historyList.length} items)',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),

            // Export Options
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildExportOption(
                      icon: Icons.picture_as_pdf_rounded,
                      color: AppTheme.errorColor,
                      title: 'Export as PDF Report',
                      subtitle: 'Complete history with images and analysis',
                      onTap: () => _performBulkExport('PDF', theme),
                      theme: theme,
                    ),
                    _buildExportOption(
                      icon: Icons.table_chart_rounded,
                      color: AppTheme.successColor,
                      title: 'Export as CSV',
                      subtitle: 'Spreadsheet format for data analysis',
                      onTap: () => _performBulkExport('CSV', theme),
                      theme: theme,
                    ),
                    _buildExportOption(
                      icon: Icons.code_rounded,
                      color: AppTheme.primaryColor,
                      title: 'Export as JSON',
                      subtitle: 'Raw data format with all metadata',
                      onTap: () => _performBulkExport('JSON', theme),
                      theme: theme,
                    ),
                    _buildExportOption(
                      icon: Icons.archive_rounded,
                      color: AppTheme.warningColor,
                      title: 'Export as Archive',
                      subtitle: 'ZIP file with images and data',
                      onTap: () => _performBulkExport('ZIP', theme),
                      theme: theme,
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

  void _performBulkExport(String format, ThemeData theme) {
    Navigator.pop(context);
    final historyCount = ref.read(historyProvider).length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Exporting $historyCount detections as $format...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This may take a few moments',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    // Simulate export process with longer delay for bulk export
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$historyCount detections exported as $format successfully',
                  style: const TextStyle(
                    color: Colors.white,
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
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Share',
            textColor: theme.colorScheme.onPrimary,
            onPressed: () {
              // Implement sharing logic for bulk export
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        Icons.share_rounded,
                        color: theme.colorScheme.onPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Opening share dialog...',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppTheme.primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}

// Enhanced detection history model with additional utilities
extension DetectionHistoryExtensions on DetectionHistory {
  String get primaryObject =>
      detectedObjects.isNotEmpty ? detectedObjects.first : 'Unknown';

  String get confidenceText => '${(averageConfidence * 100).toInt()}%';

  String get objectCountText =>
      '${detectedObjects.length} object${detectedObjects.length == 1 ? '' : 's'}';

  Color get confidenceColor {
    if (averageConfidence >= 0.8) return AppTheme.successColor;
    if (averageConfidence >= 0.6) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  String get categoryText {
    if (detectedObjects.isEmpty) return 'Unknown';

    final categories = <String, int>{};
    for (final object in detectedObjects) {
      final category = _categorizeObject(object);
      categories[category] = (categories[category] ?? 0) + 1;
    }

    final primaryCategory =
        categories.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return primaryCategory.substring(0, 1).toUpperCase() +
        primaryCategory.substring(1);
  }

  String _categorizeObject(String label) {
    final lowercaseLabel = label.toLowerCase();
    if (lowercaseLabel.contains('person') ||
        lowercaseLabel.contains('people')) {
      return 'people';
    } else if (lowercaseLabel.contains('car') ||
        lowercaseLabel.contains('vehicle')) {
      return 'vehicles';
    } else if (lowercaseLabel.contains('animal') ||
        lowercaseLabel.contains('dog') ||
        lowercaseLabel.contains('cat')) {
      return 'animals';
    } else if (lowercaseLabel.contains('food') ||
        lowercaseLabel.contains('eat')) {
      return 'food';
    } else if (lowercaseLabel.contains('plant') ||
        lowercaseLabel.contains('flower')) {
      return 'plants';
    }
    return 'objects';
  }

  /// Get a human-readable description of the detection
  String get description {
    if (detectedObjects.isEmpty) return 'No objects detected';

    if (detectedObjects.length == 1) {
      return 'Detected ${detectedObjects.first}';
    } else if (detectedObjects.length <= 3) {
      return 'Detected ${detectedObjects.join(', ')}';
    } else {
      return 'Detected ${detectedObjects.take(2).join(', ')} and ${detectedObjects.length - 2} more';
    }
  }

  /// Get the detection quality based on confidence
  String get qualityText {
    if (averageConfidence >= 0.9) return 'Excellent';
    if (averageConfidence >= 0.8) return 'Very Good';
    if (averageConfidence >= 0.7) return 'Good';
    if (averageConfidence >= 0.6) return 'Fair';
    return 'Poor';
  }

  /// Get an icon representing the primary category
  IconData get categoryIcon {
    final category = categoryText.toLowerCase();
    switch (category) {
      case 'people':
        return Icons.person_rounded;
      case 'vehicles':
        return Icons.directions_car_rounded;
      case 'animals':
        return Icons.pets_rounded;
      case 'food':
        return Icons.restaurant_rounded;
      case 'plants':
        return Icons.local_florist_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  /// Get the time ago string in a more detailed format
  String get detailedTimeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes minute${minutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days day${days == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }

  /// Check if the detection is recent (within last 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference.inHours < 24;
  }

  /// Check if the detection has high confidence
  bool get hasHighConfidence => averageConfidence >= 0.8;

  /// Get a color representing the detection quality
  Color get qualityColor {
    if (averageConfidence >= 0.8) return AppTheme.successColor;
    if (averageConfidence >= 0.6) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  /// Get export data as a map for serialization
  Map<String, dynamic> get exportData => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'detectedObjects': detectedObjects,
        'averageConfidence': averageConfidence,
        'imagePath': imagePath,
        'description': description,
        'category': categoryText,
        'quality': qualityText,
        'objectCount': detectedObjects.length,
        'confidencePercentage': '${(averageConfidence * 100).toInt()}%',
        'timeAgo': detailedTimeAgo,
        'isRecent': isRecent,
        'hasHighConfidence': hasHighConfidence,
      };
}
