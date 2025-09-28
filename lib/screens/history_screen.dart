// screens/history_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
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

  void _performExport(
      DetectionHistory item, String format, ThemeData theme) async {
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

    try {
      String? filePath;

      switch (format) {
        case 'PDF':
          filePath = await _exportToPDF(item);
          break;
        case 'CSV':
          filePath = await _exportToCSV([item]);
          break;
        case 'JSON':
          filePath = await _exportToJSON([item]);
          break;
      }

      Navigator.pop(context); // Close progress dialog

      if (filePath != null) {
        // Show success and share option
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
              onPressed: () => _shareFile(filePath!),
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close progress dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error_rounded,
                color: theme.colorScheme.onError,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Export failed: ${e.toString()}',
                  style: TextStyle(
                    color: theme.colorScheme.onError,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
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
    final isPremium = ref.watch(premiumProvider).isPremium;
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

    // For premium users, show export options directly
    if (isPremium) {
      _showExportOptions(theme);
    } else {
      // For free users, show ad-supported export
      _showAdSupportedExport(theme);
    }
  }

  void _showAdSupportedExport(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
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
              child: Column(
                children: [
                  const Icon(
                    Icons.download_rounded,
                    size: 48,
                    color: AppTheme.warningColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Export History',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Watch an ad to export your entire detection history',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Ad-supported export button
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RewardedAdButton(
                      featureName: 'Export All History',
                      onRewardEarned: () {
                        Navigator.pop(context);
                        _showExportOptions(theme);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.warningColor,
                              AppTheme.warningColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.getElevationShadow(context, 4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.play_circle_filled_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Watch Ad to Export',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Premium upgrade option
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Upgrade to Premium',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Export unlimited history without ads',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/premium');
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppTheme.primaryColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Learn More',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
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

  void _showExportOptions(ThemeData theme) {
    final historyList = ref.read(historyProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: theme.colorScheme.outline.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Export All History (${historyList.length} items)',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Export Options with ScrollView
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
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
                      const SizedBox(height: 8),
                      _buildExportOption(
                        icon: Icons.table_chart_rounded,
                        color: AppTheme.successColor,
                        title: 'Export as CSV',
                        subtitle: 'Spreadsheet format for data analysis',
                        onTap: () => _performBulkExport('CSV', theme),
                        theme: theme,
                      ),
                      const SizedBox(height: 8),
                      _buildExportOption(
                        icon: Icons.code_rounded,
                        color: AppTheme.primaryColor,
                        title: 'Export as JSON',
                        subtitle: 'Raw data format with all metadata',
                        onTap: () => _performBulkExport('JSON', theme),
                        theme: theme,
                      ),
                      const SizedBox(height: 8),
                      _buildExportOption(
                        icon: Icons.archive_rounded,
                        color: AppTheme.warningColor,
                        title: 'Export as Archive',
                        subtitle: 'ZIP file with images and data',
                        onTap: () => _performBulkExport('ZIP', theme),
                        theme: theme,
                      ),
                      const SizedBox(height: 20),
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

  void _performBulkExport(String format, ThemeData theme) async {
    Navigator.pop(context);
    final historyList = ref.read(historyProvider);

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
              'Exporting ${historyList.length} detections as $format...',
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

    try {
      String? filePath;

      switch (format) {
        case 'PDF':
          filePath = await _exportBulkToPDF(historyList);
          break;
        case 'CSV':
          filePath = await _exportToCSV(historyList);
          break;
        case 'JSON':
          filePath = await _exportToJSON(historyList);
          break;
        case 'ZIP':
          filePath = await _exportToZIP(historyList);
          break;
      }

      Navigator.pop(context); // Close progress dialog

      if (filePath != null) {
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
                    '${historyList.length} detections exported as $format successfully',
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
              onPressed: () => _shareFile(filePath!),
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close progress dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error_rounded,
                color: theme.colorScheme.onError,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Bulk export failed: ${e.toString()}',
                  style: TextStyle(
                    color: theme.colorScheme.onError,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

// Add these helper methods for actual file export functionality

  Future<String?> _exportToPDF(DetectionHistory item) async {
    try {
      // Request storage permission
      if (await Permission.storage.request().isGranted ||
          await Permission.manageExternalStorage.request().isGranted) {
        final pdf = pw.Document();

        // Load image if it exists
        pw.ImageProvider? imageProvider;
        if (File(item.imagePath).existsSync()) {
          final imageBytes = await File(item.imagePath).readAsBytes();
          imageProvider = pw.MemoryImage(imageBytes);
        }

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,
                      borderRadius: pw.BorderRadius.circular(10),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'AI Vision Detection Report',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Generated on ${DateFormat('MMM d, y - h:mm a').format(DateTime.now())}',
                          style: const pw.TextStyle(
                              fontSize: 12, color: PdfColors.grey600),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 30),

                  // Detection Details
                  pw.Text(
                    'Detection Details',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 15),

                  // Image if available
                  if (imageProvider != null) ...[
                    pw.Container(
                      height: 200,
                      width: double.infinity,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.ClipRRect(
                        // borderRadius: pw.BorderRadius.circular(8),
                        child: pw.Image(imageProvider, fit: pw.BoxFit.cover),
                      ),
                    ),
                    pw.SizedBox(height: 20),
                  ],

                  // Detection Info Table
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1),
                      1: const pw.FlexColumnWidth(2),
                    },
                    children: [
                      _buildPdfTableRow(
                          'Detection Time',
                          DateFormat('MMM d, y - h:mm a')
                              .format(item.timestamp)),
                      _buildPdfTableRow(
                          'Objects Detected', item.detectedObjects.join(', ')),
                      _buildPdfTableRow('Number of Objects',
                          '${item.detectedObjects.length}'),
                      _buildPdfTableRow('Average Confidence',
                          '${(item.averageConfidence * 100).toInt()}%'),
                      _buildPdfTableRow('Detection Quality', item.qualityText),
                      _buildPdfTableRow('Category', item.categoryText),
                    ],
                  ),

                  pw.SizedBox(height: 30),

                  // Objects List
                  pw.Text(
                    'Detected Objects',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),

                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: item.detectedObjects
                        .map((object) => pw.Container(
                              margin: const pw.EdgeInsets.only(bottom: 5),
                              padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.grey100,
                                borderRadius: pw.BorderRadius.circular(15),
                              ),
                              child: pw.Text('• $object',
                                  style: const pw.TextStyle(fontSize: 12)),
                            ))
                        .toList(),
                  ),

                  pw.Spacer(),

                  // Footer
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Text(
                      'This report was generated by AI Vision Pro. For more information, visit our website.',
                      style: const pw.TextStyle(
                          fontSize: 10, color: PdfColors.grey600),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ],
              );
            },
          ),
        );

        // Save the PDF
        final directory = await getApplicationDocumentsDirectory();
        final file = File(
            '${directory.path}/detection_${item.id}_${DateTime.now().millisecondsSinceEpoch}.pdf');
        await file.writeAsBytes(await pdf.save());

        return file.path;
      } else {
        throw Exception('Storage permission denied');
      }
    } catch (e) {
      throw Exception('PDF export failed: $e');
    }
  }

  Future<String?> _exportBulkToPDF(List<DetectionHistory> items) async {
    try {
      if (await Permission.storage.request().isGranted ||
          await Permission.manageExternalStorage.request().isGranted) {
        final pdf = pw.Document();

        // Cover page
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'AI Vision Detection History',
                      style: pw.TextStyle(
                          fontSize: 32, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      'Complete Detection Report',
                      style: const pw.TextStyle(
                          fontSize: 18, color: PdfColors.grey600),
                    ),
                    pw.SizedBox(height: 40),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(20),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius: pw.BorderRadius.circular(10),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text('Total Detections: ${items.length}',
                              style: const pw.TextStyle(fontSize: 16)),
                          pw.SizedBox(height: 5),
                          pw.Text(
                              'Generated: ${DateFormat('MMM d, y - h:mm a').format(DateTime.now())}',
                              style: const pw.TextStyle(
                                  fontSize: 12, color: PdfColors.grey600)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );

        // Add pages for each detection (limit to prevent huge files)
        final limitedItems = items.take(50).toList(); // Limit to 50 items

        for (int i = 0; i < limitedItems.length; i++) {
          final item = limitedItems[i];

          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              build: (pw.Context context) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Detection ${i + 1} of ${limitedItems.length}',
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 20),

                    // Detection summary table
                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey300),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(1),
                        1: const pw.FlexColumnWidth(2),
                      },
                      children: [
                        _buildPdfTableRow(
                            'Time',
                            DateFormat('MMM d, y - h:mm a')
                                .format(item.timestamp)),
                        _buildPdfTableRow(
                            'Objects', item.detectedObjects.join(', ')),
                        _buildPdfTableRow('Confidence',
                            '${(item.averageConfidence * 100).toInt()}%'),
                        _buildPdfTableRow('Category', item.categoryText),
                      ],
                    ),
                  ],
                );
              },
            ),
          );
        }

        // Save the PDF
        final directory = await getApplicationDocumentsDirectory();
        final file = File(
            '${directory.path}/detection_history_${DateTime.now().millisecondsSinceEpoch}.pdf');
        await file.writeAsBytes(await pdf.save());

        return file.path;
      } else {
        throw Exception('Storage permission denied');
      }
    } catch (e) {
      throw Exception('Bulk PDF export failed: $e');
    }
  }

  pw.TableRow _buildPdfTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          color: PdfColors.grey100,
          child: pw.Text(label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }

  Future<String?> _exportToCSV(List<DetectionHistory> items) async {
    try {
      if (await Permission.storage.request().isGranted ||
          await Permission.manageExternalStorage.request().isGranted) {
        // Prepare CSV data
        List<List<dynamic>> rows = [
          // Header row
          [
            'ID',
            'Timestamp',
            'Date',
            'Time',
            'Detected Objects',
            'Object Count',
            'Average Confidence (%)',
            'Quality',
            'Category',
            'Image Path',
            'Description'
          ]
        ];

        // Add data rows
        for (final item in items) {
          rows.add([
            item.id,
            item.timestamp.toIso8601String(),
            DateFormat('yyyy-MM-dd').format(item.timestamp),
            DateFormat('HH:mm:ss').format(item.timestamp),
            item.detectedObjects.join('; '),
            item.detectedObjects.length,
            (item.averageConfidence * 100).toInt(),
            item.qualityText,
            item.categoryText,
            item.imagePath,
            item.description,
          ]);
        }

        // Convert to CSV string
        final csvString = const ListToCsvConverter().convert(rows);

        // Save the file
        final directory = await getApplicationDocumentsDirectory();
        final fileName = items.length == 1
            ? 'detection_${items.first.id}_${DateTime.now().millisecondsSinceEpoch}.csv'
            : 'detection_history_${DateTime.now().millisecondsSinceEpoch}.csv';
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(csvString);

        return file.path;
      } else {
        throw Exception('Storage permission denied');
      }
    } catch (e) {
      throw Exception('CSV export failed: $e');
    }
  }

  Future<String?> _exportToJSON(List<DetectionHistory> items) async {
    try {
      if (await Permission.storage.request().isGranted ||
          await Permission.manageExternalStorage.request().isGranted) {
        // Prepare JSON data
        final exportData = {
          'exportInfo': {
            'timestamp': DateTime.now().toIso8601String(),
            'version': '1.0',
            'totalDetections': items.length,
            'exportedBy': 'AI Vision Pro',
          },
          'detections': items.map((item) => item.exportData).toList(),
        };

        // Convert to JSON string with pretty formatting
        final jsonString =
            const JsonEncoder.withIndent('  ').convert(exportData);

        // Save the file
        final directory = await getApplicationDocumentsDirectory();
        final fileName = items.length == 1
            ? 'detection_${items.first.id}_${DateTime.now().millisecondsSinceEpoch}.json'
            : 'detection_history_${DateTime.now().millisecondsSinceEpoch}.json';
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(jsonString);

        return file.path;
      } else {
        throw Exception('Storage permission denied');
      }
    } catch (e) {
      throw Exception('JSON export failed: $e');
    }
  }

  Future<String?> _exportToZIP(List<DetectionHistory> items) async {
    try {
      if (await Permission.storage.request().isGranted ||
          await Permission.manageExternalStorage.request().isGranted) {
        // For ZIP functionality, you'll need to add the 'archive' package to pubspec.yaml
        // archive: ^3.4.0

        // This is a placeholder - you would implement ZIP creation here
        // using the archive package to compress JSON data and images together

        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            'detection_archive_${DateTime.now().millisecondsSinceEpoch}.zip';
        final file = File('${directory.path}/$fileName');

        // For now, just create the JSON file (you would add ZIP compression here)
        final jsonPath = await _exportToJSON(items);
        if (jsonPath != null) {
          // Copy JSON file as ZIP placeholder
          await File(jsonPath).copy(file.path);
          return file.path;
        }

        throw Exception('ZIP creation failed');
      } else {
        throw Exception('Storage permission denied');
      }
    } catch (e) {
      throw Exception('ZIP export failed: $e');
    }
  }

  Future<void> _shareFile(String filePath) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'AI Vision Detection Export',
        subject: 'Detection Results',
      );
    } catch (e) {
      // Fallback to regular share if file sharing fails
      final fileName = filePath.split('/').last;
      await Share.share(
        'Detection results exported as $fileName\n\nFile location: $filePath',
        subject: 'Detection Results',
      );
    }
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
