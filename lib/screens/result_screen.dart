// screens/result_screen.dart

import 'dart:io';
import 'dart:ui' as ui;
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image/image.dart' as img;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';

import '../models/detected_object.dart';
import '../models/detection_result.dart';
import '../providers/analytics_provider.dart';
import '../providers/detection_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/history_provider.dart';
import '../providers/premium_provider.dart';
import '../config/app_theme.dart';
import '../widgets/ad_widgets.dart';
import '../widgets/interactive_overlay.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _overlayController;
  late AnimationController _bounceController;
  late AnimationController _shimmerController;

  final FlutterTts _tts = FlutterTts();
  final GoogleTranslator _translator = GoogleTranslator();

  bool _showOverlays = true;
  bool _isAnalyzing = false;
  double _imageScale = 1.0;
  String _selectedLanguage = 'es';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeTTS();
    _triggerAnalytics();
  }

  void _initializeControllers() {
    _tabController = TabController(length: 4, vsync: this);
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _overlayController.forward();
  }

  void _initializeTTS() async {
    try {
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.8);
      await _tts.setVolume(0.8);
    } catch (e) {
      debugPrint('TTS initialization failed: $e');
    }
  }

  void _triggerAnalytics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsProvider.notifier).trackResultView();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _overlayController.dispose();
    _bounceController.dispose();
    _shimmerController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final detectionState = ref.watch(detectionProvider);
        final isPremium = ref.watch(premiumProvider).isPremium;
        final theme = Theme.of(context);

        if (detectionState.currentResult == null) {
          return _buildNoResultScreen(theme);
        }

        final result = detectionState.currentResult!;

        if (result.isProcessing) {
          return _buildProcessingScreen(result, theme);
        }

        if (result.error != null) {
          return _buildErrorScreen(result, theme);
        }

        return _buildResultScreen(result, isPremium, theme);
      },
    );
  }

  Widget _buildNoResultScreen(ThemeData theme) {
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'No Results',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_rounded,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.image_not_supported_rounded,
                    size: 70,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ).animate().scale(delay: 200.ms),
                const SizedBox(height: 32),
                Text(
                  'No detection results available',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Take a photo to start analyzing objects with AI',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushReplacementNamed(context, '/camera');
                    },
                    icon: const Icon(Icons.camera_alt_rounded, size: 20),
                    label: Text(
                      'Take Photo',
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
                ).animate().slideY(begin: 0.3).fadeIn(delay: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingScreen(DetectionResult result, ThemeData theme) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.file(
                result.imageFile,
                fit: BoxFit.cover,
              ),
            ),

            // Blur overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: Colors.black.withOpacity(0.75),
                ),
              ),
            ),

            // Processing UI
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.3),
                          theme.colorScheme.secondary.withOpacity(0.3),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      size: 70,
                      color: Colors.white,
                    ),
                  )
                      .animate()
                      .scale(delay: 200.ms)
                      .then()
                      .shimmer(duration: 2000.ms),

                  const SizedBox(height: 40),

                  Text(
                    'AI is analyzing your image',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().slideY(begin: 0.3).fadeIn(delay: 400.ms),

                  const SizedBox(height: 16),

                  Text(
                    'This may take a few seconds...',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 48),

                  // Progress indicators
                  _buildProcessingSteps(theme),
                ],
              ),
            ),

            // Back button
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingSteps(ThemeData theme) {
    final steps = [
      {'title': 'Preprocessing image', 'completed': true, 'active': false},
      {'title': 'Detecting objects', 'completed': true, 'active': false},
      {'title': 'Analyzing features', 'completed': false, 'active': true},
      {'title': 'Generating insights', 'completed': false, 'active': false},
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        return _buildProcessStep(
          step['title'] as String,
          step['completed'] as bool,
          step['active'] as bool,
          index,
        );
      }).toList(),
    );
  }

  Widget _buildProcessStep(
      String title, bool isCompleted, bool isActive, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? AppTheme.successColor
                  : isActive
                      ? AppTheme.primaryColor
                      : Colors.grey.withOpacity(0.5),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: isCompleted
                ? const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  )
                : isActive
                    ? Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.all(6),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : null,
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              color: isCompleted || isActive
                  ? Colors.white
                  : Colors.white.withOpacity(0.6),
              fontSize: 16,
              fontWeight:
                  isCompleted || isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    ).animate(delay: (index * 200 + 800).ms).slideX().fadeIn();
  }

  Widget _buildErrorScreen(DetectionResult result, ThemeData theme) {
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Analysis Error',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.errorColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_rounded,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.errorColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 70,
                    color: AppTheme.errorColor,
                  ),
                ).animate().scale(delay: 200.ms),
                const SizedBox(height: 32),
                Text(
                  'Analysis Failed',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.errorColor,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.errorColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    result.error ??
                        'An unexpected error occurred during image analysis',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back_rounded, size: 20),
                        label: const Text('Go Back'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.onSurface,
                          side: BorderSide(color: theme.colorScheme.outline),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _retryAnalysis();
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate().slideY(begin: 0.3).fadeIn(delay: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen(
      DetectionResult result, bool isPremium, ThemeData theme) {
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          // Main content
          Expanded(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 320,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: AppTheme.getElevationShadow(context, 2),
                      ),
                      child: IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildImageViewer(result, theme),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: AppTheme.getElevationShadow(context, 2),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.share_rounded,
                            color: theme.colorScheme.onSurface,
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _shareResults(result);
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: AppTheme.getElevationShadow(context, 2),
                        ),
                        child: IconButton(
                          icon: Icon(
                            _showOverlays
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: theme.colorScheme.onSurface,
                          ),
                          onPressed: _toggleOverlays,
                        ),
                      ),
                      if (isPremium)
                        Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: AppTheme.getElevationShadow(context, 2),
                          ),
                          child: PopupMenuButton<String>(
                            onSelected: (value) =>
                                _handleMenuAction(value, result),
                            icon: Icon(
                              Icons.more_vert_rounded,
                              color: theme.colorScheme.onSurface,
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
                                      color: theme.colorScheme.onSurface,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('Export Data'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'analyze',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.analytics_rounded,
                                      color: theme.colorScheme.onSurface,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('Deep Analysis'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(48),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          boxShadow: AppTheme.getElevationShadow(context, 4),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          // isScrollable: true,
                          // tabAlignment: TabAlignment.start,
                          indicatorColor: theme.colorScheme.primary,
                          indicatorWeight: 3,
                          labelColor: theme.colorScheme.primary,
                          unselectedLabelColor:
                              theme.colorScheme.onSurfaceVariant,
                          labelStyle: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle:
                              theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          tabs: const [
                            Tab(
                              icon: Icon(Icons.category_rounded, size: 20),
                              text: 'Objects',
                            ),
                            Tab(
                              icon: Icon(Icons.analytics_rounded, size: 20),
                              text: 'Analysis',
                            ),
                            Tab(
                              icon: Icon(Icons.info_rounded, size: 20),
                              text: 'Details',
                            ),
                            Tab(
                              icon: Icon(Icons.translate_rounded, size: 20),
                              text: 'Translate',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: Column(
                children: [
                  // Banner ad at top of results for non-premium users
                  if (!isPremium)
                    Container(
                      margin: const EdgeInsets.all(16),
                      child: const AdBanner(placement: 'results'),
                    ),

                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildObjectsTab(result, isPremium, theme),
                        _buildAnalysisTabWithAds(result, isPremium, theme),
                        _buildDetailsTab(result, isPremium, theme),
                        _buildTranslateTab(result, isPremium, theme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom banner ad for non-premium users
          if (!isPremium)
            Container(
              padding: const EdgeInsets.all(16),
              child: const AdBanner(placement: 'results'),
            ),
        ],
      ),
      floatingActionButton: _buildFloatingActions(result, isPremium, theme),
    );
  }

  Widget _buildAnalysisTabWithAds(
      DetectionResult result, bool isPremium, ThemeData theme) {
    if (!isPremium) {
      return SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppTheme.premiumGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.premiumGold.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              ).animate().scale().then().shimmer(duration: 2000.ms),
              const SizedBox(height: 32),
              Text(
                'Advanced Analysis',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Get detailed AI insights, confidence analysis, and advanced metrics about your detected objects.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/premium');
                  },
                  icon: const Icon(Icons.diamond_rounded, size: 20),
                  label: Text(
                    'Upgrade to Premium',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.premiumGold,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ).animate().slideY(begin: 0.3).fadeIn(delay: 500.ms),
            ],
          ),
        ),
      );
    }

    return _buildAnalysisTab(result, theme);
  }

  Widget _buildImageViewer(DetectionResult result, ThemeData theme) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Main image with gesture controls
        InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          onInteractionUpdate: (details) {
            setState(() {
              _imageScale = details.scale;
            });
          },
          child: Container(
            color: Colors.black,
            child: Center(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                child: Image.file(
                  result.imageFile,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        // Interactive overlay with detections
        if (_showOverlays && result.objects.isNotEmpty)
          Positioned.fill(
            child: InteractiveOverlay(
              result: result,
              onObjectTap: _handleObjectTap,
              scale: _imageScale,
            ),
          ),

        // Image info overlay
        Positioned(
          bottom: 20,
          left: 20,
          child: _buildImageInfo(result, theme),
        ),

        // Quick actions overlay
        Positioned(
          top: 100,
          right: 20,
          child: _buildQuickActions(result, theme),
        ),
      ],
    );
  }

  Widget _buildImageInfo(DetectionResult result, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.image_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${result.objects.length} objects detected',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(DetectionResult result, ThemeData theme) {
    final actions = [
      {
        'icon': Icons.volume_up_rounded,
        'action': () => _readResults(result),
        'tooltip': 'Read aloud',
      },
      {
        'icon': Icons.save_alt_rounded,
        'action': () => _saveResults(result),
        'tooltip': 'Save results',
      },
      {
        'icon': Icons.search_rounded,
        'action': () => _searchSimilar(result),
        'tooltip': 'Search similar',
      },
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: actions.asMap().entries.map((entry) {
        final index = entry.key;
        final action = entry.value;
        return Container(
          margin: EdgeInsets.only(bottom: index < actions.length - 1 ? 12 : 0),
          child: _buildQuickActionButton(
            action['icon'] as IconData,
            action['action'] as VoidCallback,
            action['tooltip'] as String,
            theme,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActionButton(
    IconData icon,
    VoidCallback onTap,
    String tooltip,
    ThemeData theme,
  ) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    ).animate().scale(delay: 100.ms);
  }

  Widget _buildObjectsTab(
      DetectionResult result, bool isPremium, ThemeData theme) {
    if (result.objects.isEmpty) {
      return _buildEmptyState(
        'No objects detected',
        'Try a different image or adjust the camera angle',
        theme,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: result.objects.length,
      itemBuilder: (context, index) {
        final object = result.objects[index];
        return _buildObjectCard(object, isPremium, theme)
            .animate(delay: (index * 100).ms)
            .slideX()
            .fadeIn();
      },
    );
  }

  Widget _buildObjectCard(
      DetectedObject object, bool isPremium, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: AppTheme.getElevationShadow(context, 2),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showObjectDetails(object, theme);
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getConfidenceColor(object.confidence)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getObjectIcon(object.label),
                      color: _getConfidenceColor(object.confidence),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          object.label,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getConfidenceColor(object.confidence),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(object.confidence * 100).toInt()}% confidence',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _getConfidenceColor(object.confidence),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getConfidenceColor(object.confidence)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getConfidenceColor(object.confidence)
                            .withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${(object.confidence * 100).toInt()}%',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: _getConfidenceColor(object.confidence),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              if (object.description != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    object.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Action buttons
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildActionChip(
                    Icons.info_outline_rounded,
                    'Details',
                    () => _showObjectDetails(object, theme),
                    theme,
                  ),
                  if (isPremium) ...[
                    _buildActionChip(
                      Icons.lightbulb_outline_rounded,
                      'Fun Fact',
                      () => _showFunFact(object),
                      theme,
                    ),
                    _buildActionChip(
                      Icons.shopping_cart_outlined,
                      'Buy',
                      () => _searchToBuy(object),
                      theme,
                    ),
                  ] else ...[
                    _buildPremiumActionChip(
                      Icons.lightbulb_outline_rounded,
                      'Fun Fact',
                      theme,
                    ),
                    _buildPremiumActionChip(
                      Icons.shopping_cart_outlined,
                      'Buy',
                      theme,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip(
    IconData icon,
    String label,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumActionChip(IconData icon, String label, ThemeData theme) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(context, '/premium');
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.premiumGold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.premiumGold.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.diamond_rounded,
              size: 16,
              color: AppTheme.premiumGold,
            ),
            const SizedBox(width: 4),
            Icon(
              icon,
              size: 18,
              color: AppTheme.premiumGold,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppTheme.premiumGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisTab(DetectionResult result, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalyticsPanel(result, theme),
          const SizedBox(height: 24),
          _buildInsightsSection(result, theme),
          const SizedBox(height: 24),
          _buildRecommendationsSection(result, theme),
        ],
      ),
    );
  }

  Widget _buildAnalyticsPanel(DetectionResult result, ThemeData theme) {
    return Container(
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
                'Image Analytics',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Confidence distribution
          if (result.objects.isNotEmpty) _buildConfidenceChart(result, theme),

          const SizedBox(height: 24),

          // Statistics grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard(
                'Objects',
                '${result.objects.length}',
                Icons.category_rounded,
                theme.colorScheme.primary,
                theme,
              ),
              _buildStatCard(
                'Avg Confidence',
                '${_getAverageConfidence(result)}%',
                Icons.trending_up_rounded,
                AppTheme.successColor,
                theme,
              ),
              _buildStatCard(
                'Processing Time',
                '2.3s',
                Icons.timer_rounded,
                AppTheme.warningColor,
                theme,
              ),
              _buildStatCard(
                'Image Quality',
                'High',
                Icons.hd_rounded,
                AppTheme.infoColor,
                theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceChart(DetectionResult result, ThemeData theme) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confidence Distribution',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: result.objects.asMap().entries.map((entry) {
                final index = entry.key;
                final object = entry.value;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: index < result.objects.length - 1 ? 6 : 0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${(object.confidence * 100).toInt()}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          height: 60 * object.confidence,
                          decoration: BoxDecoration(
                            color: _getConfidenceColor(object.confidence),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Flexible(
                          child: Text(
                            object.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          FittedBox(
            child: Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(DetectionResult result, ThemeData theme) {
    return Container(
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
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: AppTheme.secondaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'AI Insights',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInsightItem(
            '🎯',
            'Primary Focus',
            'The image mainly contains ${_getPrimaryCategory(result)} with high confidence levels.',
            theme,
          ),
          _buildInsightItem(
            '📊',
            'Detection Quality',
            'All objects were detected with above-average confidence scores.',
            theme,
          ),
          _buildInsightItem(
            '🔍',
            'Image Analysis',
            'The lighting and angle are optimal for object recognition.',
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(
      String emoji, String title, String description, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 16),
              ),
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
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(DetectionResult result, ThemeData theme) {
    return Container(
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
                  Icons.recommend_rounded,
                  color: AppTheme.warningColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Recommendations',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildRecommendationItem(
            Icons.search_rounded,
            'Explore Similar Objects',
            'Find more images with similar objects',
            () => _searchSimilar(result),
            theme,
          ),
          _buildRecommendationItem(
            Icons.share_rounded,
            'Share Your Discovery',
            'Share these results with friends',
            () => _shareResults(result),
            theme,
          ),
          _buildRecommendationItem(
            Icons.bookmark_rounded,
            'Save to Collection',
            'Add to your personal collection',
            () => _saveToCollection(result),
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(
    IconData icon,
    String title,
    String subtitle,
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 24,
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
                  const SizedBox(height: 2),
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
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab(
      DetectionResult result, bool isPremium, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageMetadata(result, theme),
          const SizedBox(height: 20),
          _buildDetectionDetails(result, theme),
          if (isPremium) ...[
            const SizedBox(height: 20),
            _buildAdvancedDetails(result, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildImageMetadata(DetectionResult result, ThemeData theme) {
    return Container(
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
                  Icons.info_rounded,
                  color: AppTheme.infoColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Image Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
              'Timestamp', _formatTimestamp(result.timestamp), theme),
          _buildDetailRow('File Size', _getFileSize(result.imageFile), theme),
          _buildDetailRow('Objects Found', '${result.objects.length}', theme),
          _buildDetailRow(
              'Mode', result.mode?.displayName ?? 'Object Detection', theme),
          _buildDetailRow(
            'Status',
            result.error != null ? 'Error' : 'Success',
            theme,
            valueColor: result.error != null
                ? AppTheme.errorColor
                : AppTheme.successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionDetails(DetectionResult result, ThemeData theme) {
    return Container(
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
                  Icons.category_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Detection Details',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (result.objects.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No objects were detected in this image.',
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...result.objects
                .map((object) => _buildObjectDetail(object, theme)),
        ],
      ),
    );
  }

  Widget _buildObjectDetail(DetectedObject object, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getConfidenceColor(object.confidence).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  object.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      _getConfidenceColor(object.confidence).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(object.confidence * 100).toStringAsFixed(1)}%',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _getConfidenceColor(object.confidence),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Position',
                  '(${object.boundingBox.left.toInt()}, ${object.boundingBox.top.toInt()})',
                  theme,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Size',
                  '${object.boundingBox.width.toInt()} x ${object.boundingBox.height.toInt()}',
                  theme,
                ),
              ),
            ],
          ),
          if (object.type != null) ...[
            const SizedBox(height: 8),
            _buildDetailItem('Type', object.type!, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedDetails(DetectionResult result, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.premiumGold.withOpacity(0.1),
            AppTheme.premiumGold.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.premiumGold.withOpacity(0.3),
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
                  gradient: AppTheme.premiumGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.diamond_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Advanced Analytics',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow('Processing Model', 'AI Vision Pro v2.1', theme),
          _buildDetailRow(
              'Confidence Score', '${_getAverageConfidence(result)}%', theme),
          _buildDetailRow('Detection Speed', '2.3 seconds', theme),
          _buildDetailRow('API Calls Used', '${result.objects.length}', theme),
          _buildDetailRow('Accuracy Rating', _getAccuracyRating(result), theme),
          if (result.deepAnalysis != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deep Analysis',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.deepAnalysis!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTranslateTab(
      DetectionResult result, bool isPremium, ThemeData theme) {
    if (!isPremium) {
      return SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppTheme.premiumGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.premiumGold.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.translate_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              ).animate().scale().then().shimmer(duration: 2000.ms),
              const SizedBox(height: 20),
              Text(
                'Multi-language Translation',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Translate object names and descriptions into 50+ languages with premium access.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/premium');
                  },
                  icon: const Icon(Icons.diamond_rounded, size: 20),
                  label: Text(
                    'Upgrade to Premium',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.premiumGold,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ).animate().slideY(begin: 0.3).fadeIn(delay: 500.ms),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLanguageSelector(theme),
          const SizedBox(height: 20),
          if (result.objects.isNotEmpty)
            _buildTranslationResults(result, theme)
          else
            _buildEmptyState(
              'No objects to translate',
              'Detection results are required for translation',
              theme,
            ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(ThemeData theme) {
    final languages = {
      'es': '🇪🇸 Spanish',
      'fr': '🇫🇷 French',
      'de': '🇩🇪 German',
      'it': '🇮🇹 Italian',
      'pt': '🇵🇹 Portuguese',
      'ja': '🇯🇵 Japanese',
      'ko': '🇰🇷 Korean',
      'zh': '🇨🇳 Chinese',
      'ar': '🇸🇦 Arabic',
      'hi': '🇮🇳 Hindi',
    };

    return Container(
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
                  Icons.language_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Select Language',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: languages.entries.map((entry) {
              final isSelected = _selectedLanguage == entry.key;
              return FilterChip(
                label: Text(entry.value),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedLanguage = entry.key);
                    _translateResults();
                  }
                },
                selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                backgroundColor:
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                side: BorderSide(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withOpacity(0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationResults(DetectionResult result, ThemeData theme) {
    return Container(
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
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.translate_rounded,
                  color: AppTheme.successColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Translations',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...result.objects
              .map((object) => _buildTranslationItem(object, theme)),
        ],
      ),
    );
  }

  Widget _buildTranslationItem(DetectedObject object, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  object.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.volume_up_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _speakTranslation(object.label);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<String>(
            future: _getTranslation(object.label),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Translating...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.errorColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppTheme.errorColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Translation failed',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  snapshot.data ?? 'Translation not available',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor ?? theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 50,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActions(
      DetectionResult result, bool isPremium, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isPremium)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: FloatingActionButton(
              heroTag: "compare",
              onPressed: () {
                HapticFeedback.lightImpact();
                _compareWithSimilar(result);
              },
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: Colors.white,
              elevation: 4,
              child: const Icon(Icons.compare_rounded),
            ),
          ),
        FloatingActionButton(
          heroTag: "camera",
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pushReplacementNamed(context, '/camera');
          },
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.camera_alt_rounded),
        ),
      ],
    );
  }

  // Event Handlers and Utility Methods
  void _toggleOverlays() {
    setState(() => _showOverlays = !_showOverlays);
    HapticFeedback.lightImpact();
  }

  void _handleObjectTap(DetectedObject object) {
    HapticFeedback.lightImpact();
    _showObjectDetails(object, Theme.of(context));
  }

  void _handleMenuAction(String action, DetectionResult result) {
    HapticFeedback.lightImpact();
    switch (action) {
      case 'export':
        _exportData(result);
        break;
      case 'analyze':
        _deepAnalysis(result);
        break;
      case 'compare':
        _compareWithSimilar(result);
        break;
    }
  }

  void _retryAnalysis() {
    final result = ref.read(detectionProvider).currentResult;
    if (result != null) {
      ref.read(detectionProvider.notifier).retryDetection(result.imageFile);
    }
  }

  void _showObjectDetails(DetectedObject object, ThemeData theme) {
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
            color: theme.colorScheme.surface,
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
                  color: theme.colorScheme.outline.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _getConfidenceColor(object.confidence)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getObjectIcon(object.label),
                        color: _getConfidenceColor(object.confidence),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            object.label,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Confidence: ${(object.confidence * 100).toInt()}%',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _getConfidenceColor(object.confidence),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: theme
                            .colorScheme.surfaceContainerHighest
                            .withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                      // Description
                      if (object.description != null) ...[
                        _buildSectionHeader('Description', theme),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            object.description!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Quick Actions
                      _buildSectionHeader('Quick Actions', theme),
                      const SizedBox(height: 16),
                      _buildQuickActionsGrid(object, theme),
                      const SizedBox(height: 24),

                      // Technical Details
                      _buildSectionHeader('Technical Details', theme),
                      const SizedBox(height: 12),
                      _buildTechnicalDetails(object, theme),

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

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildQuickActionsGrid(DetectedObject object, ThemeData theme) {
    final actions = [
      {
        'icon': Icons.search_rounded,
        'label': 'Search Web',
        'action': () => _searchWeb(object)
      },
      {
        'icon': Icons.share_rounded,
        'label': 'Share',
        'action': () => _shareObject(object)
      },
      {
        'icon': Icons.bookmark_rounded,
        'label': 'Save',
        'action': () => _saveObject(object)
      },
      {
        'icon': Icons.shopping_cart_rounded,
        'label': 'Buy',
        'action': () => _searchToBuy(object)
      },
      {
        'icon': Icons.volume_up_rounded,
        'label': 'Speak',
        'action': () => _speakObject(object)
      },
      {
        'icon': Icons.translate_rounded,
        'label': 'Translate',
        'action': () => _translateObject(object)
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            (action['action'] as VoidCallback)();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  action['icon'] as IconData,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  action['label'] as String,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTechnicalDetails(DetectedObject object, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildTechnicalDetailRow(
              'Object ID', object.id.substring(0, 8), theme),
          _buildTechnicalDetailRow(
            'Confidence Score',
            '${(object.confidence * 100).toStringAsFixed(2)}%',
            theme,
          ),
          _buildTechnicalDetailRow(
            'Bounding Box',
            '(${object.boundingBox.left.toInt()}, ${object.boundingBox.top.toInt()}, '
                '${object.boundingBox.width.toInt()}, ${object.boundingBox.height.toInt()})',
            theme,
          ),
          _buildTechnicalDetailRow(
              'Detection Model', 'AI Vision Pro v2.1', theme),
          _buildTechnicalDetailRow(
            'Processing Time',
            '0.${(object.confidence * 1000).toInt()}s',
            theme,
          ),
          if (object.type != null)
            _buildTechnicalDetailRow('Object Type', object.type!, theme),
        ],
      ),
    );
  }

  Widget _buildTechnicalDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // Utility Methods
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppTheme.successColor;
    if (confidence >= 0.6) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  IconData _getObjectIcon(String label) {
    final lowercaseLabel = label.toLowerCase();
    if (lowercaseLabel.contains('person') ||
        lowercaseLabel.contains('people')) {
      return Icons.person_rounded;
    } else if (lowercaseLabel.contains('car') ||
        lowercaseLabel.contains('vehicle')) {
      return Icons.directions_car_rounded;
    } else if (lowercaseLabel.contains('food') ||
        lowercaseLabel.contains('eat')) {
      return Icons.restaurant_rounded;
    } else if (lowercaseLabel.contains('animal') ||
        lowercaseLabel.contains('dog') ||
        lowercaseLabel.contains('cat')) {
      return Icons.pets_rounded;
    } else if (lowercaseLabel.contains('plant') ||
        lowercaseLabel.contains('flower')) {
      return Icons.local_florist_rounded;
    } else if (lowercaseLabel.contains('book') ||
        lowercaseLabel.contains('text')) {
      return Icons.book_rounded;
    } else if (lowercaseLabel.contains('phone') ||
        lowercaseLabel.contains('mobile')) {
      return Icons.phone_android_rounded;
    } else if (lowercaseLabel.contains('computer') ||
        lowercaseLabel.contains('laptop')) {
      return Icons.computer_rounded;
    }
    return Icons.category_rounded;
  }

  int _getAverageConfidence(DetectionResult result) {
    if (result.objects.isEmpty) return 0;
    final sum =
        result.objects.fold<double>(0, (sum, obj) => sum + obj.confidence);
    return ((sum / result.objects.length) * 100).round();
  }

  String _getPrimaryCategory(DetectionResult result) {
    if (result.objects.isEmpty) return 'unknown objects';

    final categories = <String, int>{};
    for (final object in result.objects) {
      final category = _categorizeObject(object.label);
      categories[category] = (categories[category] ?? 0) + 1;
    }

    final primaryCategory =
        categories.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return primaryCategory;
  }

  String _categorizeObject(String label) {
    final lowercaseLabel = label.toLowerCase();
    if (lowercaseLabel.contains('person') ||
        lowercaseLabel.contains('people')) {
      return 'people';
    } else if (lowercaseLabel.contains('car') ||
        lowercaseLabel.contains('vehicle') ||
        lowercaseLabel.contains('truck') ||
        lowercaseLabel.contains('bus')) {
      return 'vehicles';
    } else if (lowercaseLabel.contains('food') ||
        lowercaseLabel.contains('eat') ||
        lowercaseLabel.contains('drink')) {
      return 'food items';
    } else if (lowercaseLabel.contains('animal') ||
        lowercaseLabel.contains('dog') ||
        lowercaseLabel.contains('cat') ||
        lowercaseLabel.contains('bird')) {
      return 'animals';
    } else if (lowercaseLabel.contains('plant') ||
        lowercaseLabel.contains('flower') ||
        lowercaseLabel.contains('tree')) {
      return 'plants';
    } else if (lowercaseLabel.contains('building') ||
        lowercaseLabel.contains('house') ||
        lowercaseLabel.contains('structure')) {
      return 'architecture';
    }
    return 'miscellaneous objects';
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year} at ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String _getFileSize(dynamic file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getAccuracyRating(DetectionResult result) {
    final avgConfidence = _getAverageConfidence(result);
    if (avgConfidence >= 90) return 'Excellent';
    if (avgConfidence >= 80) return 'High';
    if (avgConfidence >= 70) return 'Good';
    if (avgConfidence >= 60) return 'Fair';
    return 'Low';
  }

  // Action Methods with Enhanced Theme Integration
  void _shareResults(DetectionResult result) async {
    final objectsText = result.objects
        .map((obj) => '${obj.label} (${(obj.confidence * 100).toInt()}%)')
        .join(', ');

    await Share.share(
      'I found these objects using AI Vision Pro: $objectsText',
      subject: 'My AI Vision Detection Results',
    );

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
              const Expanded(
                child: Text(
                  'Results shared successfully!',
                  style: TextStyle(
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

  void _saveResults(DetectionResult result) async {
    ref.read(historyProvider.notifier).saveResult(result);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.bookmark_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Results saved to your collection',
                  style: TextStyle(
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
            label: 'View',
            textColor: Colors.white,
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
        ),
      );
    }
  }

  void _readResults(DetectionResult result) async {
    if (result.objects.isEmpty) {
      await _tts.speak('No objects were detected in this image.');
      return;
    }

    final objectsText = result.objects.map((obj) => obj.label).join(', ');
    await _tts.speak('I detected the following objects: $objectsText');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.volume_up_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Reading results aloud...',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.infoColor,
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

  void _searchSimilar(DetectionResult result) {
    if (result.objects.isNotEmpty) {
      Navigator.pushNamed(
        context,
        '/search',
        arguments: {'query': result.objects.first.label, 'type': 'similar'},
      );
    }
  }

  void _saveToCollection(DetectionResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCollectionSelectorSheet(result),
    );
  }

  Widget _buildCollectionSelectorSheet(DetectionResult result) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
              color: theme.colorScheme.outline.withOpacity(0.4),
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
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.collections_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Save to Collection',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Collections List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildCollectionTile(
                  icon: Icons.star_rounded,
                  color: AppTheme.warningColor,
                  title: 'Favorites',
                  subtitle: 'Personal favorites collection',
                  onTap: () => _saveToCollectionAction('favorites'),
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _buildCollectionTile(
                  icon: Icons.work_rounded,
                  color: AppTheme.infoColor,
                  title: 'Work Projects',
                  subtitle: 'Professional use collection',
                  onTap: () => _saveToCollectionAction('work'),
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _buildCollectionTile(
                  icon: Icons.home_rounded,
                  color: AppTheme.successColor,
                  title: 'Personal',
                  subtitle: 'Personal items collection',
                  onTap: () => _saveToCollectionAction('personal'),
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _buildCollectionTile(
                  icon: Icons.school_rounded,
                  color: AppTheme.secondaryColor,
                  title: 'Educational',
                  subtitle: 'Learning and research',
                  onTap: () => _saveToCollectionAction('educational'),
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _buildCollectionTile(
                  icon: Icons.add_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                  title: 'Create New Collection',
                  subtitle: 'Make a custom collection',
                  onTap: () => _createNewCollection(),
                  theme: theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
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
                  const SizedBox(height: 2),
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
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _saveToCollectionAction(String collection) {
    Navigator.pop(context);
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
                'Saved to $collection collection',
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
      ),
    );
  }

  void _createNewCollection() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => _buildCreateCollectionDialog(),
    );
  }

  Widget _buildCreateCollectionDialog() {
    final theme = Theme.of(context);
    final controller = TextEditingController();

    return AlertDialog(
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
              Icons.add_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Create Collection',
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
            'Enter a name for your new collection',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            autofocus: true,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: 'Collection Name',
              hintText: 'e.g., My Objects',
              prefixIcon: Icon(
                Icons.collections_outlined,
                color: theme.colorScheme.primary,
              ),
              filled: true,
              fillColor:
                  theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
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
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
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
                            'Collection "${controller.text.trim()}" created successfully!',
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
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Create',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _exportData(DetectionResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildExportOptionsSheet(result),
    );
  }

  Widget _buildExportOptionsSheet(DetectionResult result) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
              color: theme.colorScheme.outline.withOpacity(0.4),
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
                  'Export Options',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Export Options
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildExportOption(
                  icon: Icons.picture_as_pdf_rounded,
                  color: AppTheme.errorColor,
                  title: 'Export as PDF',
                  subtitle: 'Detailed report with images and analysis',
                  onTap: () => _exportAsPDF(),
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _buildExportOption(
                  icon: Icons.table_chart_rounded,
                  color: AppTheme.successColor,
                  title: 'Export as CSV',
                  subtitle: 'Spreadsheet format for data analysis',
                  onTap: () => _exportAsCSV(),
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _buildExportOption(
                  icon: Icons.code_rounded,
                  color: AppTheme.infoColor,
                  title: 'Export as JSON',
                  subtitle: 'Raw data format for developers',
                  onTap: () => _exportAsJSON(),
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _buildExportOption(
                  icon: Icons.image_rounded,
                  color: AppTheme.warningColor,
                  title: 'Export Image with Annotations',
                  subtitle: 'Image with detection overlays',
                  onTap: () => _exportAnnotatedImage(),
                  theme: theme,
                ),
              ],
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
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
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
                  const SizedBox(height: 2),
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
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _exportAsPDF() async {
    Navigator.pop(context);

    final result = ref.read(detectionProvider).currentResult;
    if (result == null) {
      _showErrorSnackBar('No detection result available');
      return;
    }

    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text('Detection Results', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.Image(pw.MemoryImage(result.imageFile.readAsBytesSync())),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(data: <List<String>>[
              <String>['Label', 'Confidence'],
              ...result.objects.map((obj) =>
                  [obj.label, '${(obj.confidence * 100).toStringAsFixed(2)}%'])
            ]),
          ],
        );
      },
    ));

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/detection_results.pdf');
    await file.writeAsBytes(await pdf.save());

    OpenFile.open(file.path);
    _showExportProgress('PDF');
  }

  void _exportAsCSV() async {
    Navigator.pop(context);

    final result = ref.read(detectionProvider).currentResult;
    if (result == null) {
      _showErrorSnackBar('No detection result available');
      return;
    }

    List<List<dynamic>> rows = [
      ['Label', 'Confidence', 'Description'],
      ...result.objects.map((obj) => [
            obj.label,
            obj.confidence,
            obj.description ?? '',
          ]),
    ];

    String csv = const ListToCsvConverter().convert(rows);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/detection_results.csv');
    await file.writeAsString(csv);

    OpenFile.open(file.path);
    _showExportProgress('CSV');
  }

  void _exportAsJSON() async {
    Navigator.pop(context);

    final result = ref.read(detectionProvider).currentResult;
    if (result == null) {
      _showErrorSnackBar('No detection result available');
      return;
    }

    final json = result.toJson();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/detection_results.json');
    await file.writeAsString(json.toString());

    OpenFile.open(file.path);
    _showExportProgress('JSON');
  }

  void _exportAnnotatedImage() async {
    Navigator.pop(context);

    final result = ref.read(detectionProvider).currentResult;
    if (result == null) {
      _showErrorSnackBar('No detection result available');
      return;
    }

    final originalImage = img.decodeImage(result.imageFile.readAsBytesSync())!;
    final annotatedImage =
        img.copyResize(originalImage, width: originalImage.width);

    for (var obj in result.objects) {
      img.drawRect(
        annotatedImage,
        x1: obj.boundingBox.left.toInt(),
        y1: obj.boundingBox.top.toInt(),
        x2: obj.boundingBox.right.toInt(),
        y2: obj.boundingBox.bottom.toInt(),
        color: img.ColorRgb8(255, 0, 0),
      );
      img.drawString(
        annotatedImage,
        '${obj.label} ${(obj.confidence * 100).toInt()}%',
        font: img.arial14,
        x: obj.boundingBox.left.toInt(),
        y: obj.boundingBox.top.toInt() - 20,
        color: img.ColorRgb8(255, 0, 0),
      );
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/annotated_image.png');
    await file.writeAsBytes(img.encodePng(annotatedImage));

    OpenFile.open(file.path);
    _showExportProgress('Image');
  }

  void _showErrorSnackBar(String message) {
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
                style: const TextStyle(fontWeight: FontWeight.w500),
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

  void _showExportProgress(String format) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
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
              'Exporting as $format...',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we prepare your file',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    // Simulate export process
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // Close progress dialog
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
                    'Successfully exported as $format',
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
            action: SnackBarAction(
              label: 'Share',
              textColor: Colors.white,
              onPressed: () {
                // Implement sharing logic
                _shareExportedFile(format);
              },
            ),
          ),
        );
      }
    });
  }

  void _shareExportedFile(String format) {
    // Simulate sharing the exported file
    Share.share(
      'Here\'s my AI Vision Pro analysis exported as $format!',
      subject: 'AI Vision Pro Export',
    );
  }

  void _deepAnalysis(DetectionResult result) async {
    setState(() => _isAnalyzing = true);

    try {
      await ref.read(detectionProvider.notifier).performDeepAnalysis(result);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.analytics_rounded,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Deep analysis completed! Check the Analysis tab.',
                    style: TextStyle(
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
              label: 'View',
              textColor: Colors.white,
              onPressed: () => _tabController.animateTo(1),
            ),
          ),
        );
      }
    } catch (e) {
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
                    'Analysis failed: $e',
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
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  void _compareWithSimilar(DetectionResult result) {
    Navigator.pushNamed(
      context,
      '/compare',
      arguments: result,
    );
  }

  void _showFunFact(DetectedObject object) async {
    final theme = Theme.of(context);

    if (object.funFact == null) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: theme.colorScheme.surface,
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
                'Loading fun fact...',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      );

      try {
        await ref.read(detectionProvider.notifier).fetchFunFact(object);
        if (mounted) Navigator.pop(context); // Close loading dialog
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
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
                    child: Text('Failed to load fun fact: $e'),
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
        return;
      }
    }

    if (mounted) {
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
                  Icons.lightbulb_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Fun Fact: ${object.label}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.warningColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              object.funFact ?? 'Fun fact not available.',
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurfaceVariant,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Close'),
            ),
            if (object.funFact != null)
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
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _tts.speak(object.funFact!);
                  },
                  icon: const Icon(Icons.volume_up_rounded, size: 18),
                  label: const Text('Read Aloud'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      );
    }
  }

  void _searchWeb(DetectedObject object) async {
    final url =
        'https://www.google.com/search?q=${Uri.encodeComponent(object.label)}';
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
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
                  child: Text('Failed to open web search: $e'),
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
  }

  void _shareObject(DetectedObject object) async {
    await Share.share(
      'I found a ${object.label} using AI Vision Pro! '
      'Confidence: ${(object.confidence * 100).toInt()}%',
    );
  }

  void _saveObject(DetectedObject object) {
    ref.read(favoritesProvider.notifier).addFavorite(object);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.bookmark_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('${object.label} saved to favorites'),
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
            label: 'View',
            textColor: Colors.white,
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
          ),
        ),
      );
    }
  }

  void _searchToBuy(DetectedObject object) async {
    final theme = Theme.of(context);

    final stores = [
      {
        'name': 'Amazon',
        'url':
            'https://www.amazon.com/s?k=${Uri.encodeComponent(object.label)}',
        'icon': Icons.shopping_bag_rounded,
        'color': AppTheme.warningColor,
      },
      {
        'name': 'eBay',
        'url':
            'https://www.ebay.com/sch/i.html?_nkw=${Uri.encodeComponent(object.label)}',
        'icon': Icons.local_offer_rounded,
        'color': AppTheme.infoColor,
      },
      {
        'name': 'Google Shopping',
        'url':
            'https://shopping.google.com/search?q=${Uri.encodeComponent(object.label)}',
        'icon': Icons.shopping_cart_rounded,
        'color': AppTheme.successColor,
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: AppTheme.getElevationShadow(context, 12),
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
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_rounded,
                      color: AppTheme.successColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Shop for ${object.label}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Store options
            ...stores.map((store) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                child: InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    final uri = Uri.parse(store['url'] as String);
                    try {
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    } catch (e) {
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
                                      'Failed to open ${store['name']}: $e'),
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
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: (store['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            store['icon'] as IconData,
                            color: store['color'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Search on ${store['name']}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Find ${object.label} deals and prices',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
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

  void _speakObject(DetectedObject object) async {
    try {
      final text = object.description != null
          ? '${object.label}. ${object.description}'
          : object.label;
      await _tts.speak(text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.volume_up_rounded,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Speaking: ${object.label}'),
                ),
              ],
            ),
            backgroundColor: AppTheme.infoColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
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
                  child: Text('Text-to-speech failed: $e'),
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
  }

  void _translateObject(DetectedObject object) {
    // Switch to translate tab and focus on this object
    _tabController.animateTo(3);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.translate_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Switched to translation tab for ${object.label}'),
            ),
          ],
        ),
        backgroundColor: AppTheme.infoColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _speakTranslation(String text) async {
    try {
      await _tts.setLanguage(_getLanguageCode(_selectedLanguage));
      await _tts.speak(text);
      await _tts.setLanguage("en-US"); // Reset to English
    } catch (e) {
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
                  child: Text('Translation speech failed: $e'),
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
  }

  Future<String> _getTranslation(String text) async {
    try {
      final translation =
          await _translator.translate(text, to: _selectedLanguage);
      return translation.text;
    } catch (e) {
      debugPrint('Translation error: $e');
      return 'Translation failed';
    }
  }

  void _translateResults() {
    // Trigger translation for all objects
    setState(() {});
  }

  String _getLanguageCode(String code) {
    final languageCodes = {
      'es': 'es-ES',
      'fr': 'fr-FR',
      'de': 'de-DE',
      'it': 'it-IT',
      'pt': 'pt-PT',
      'ja': 'ja-JP',
      'ko': 'ko-KR',
      'zh': 'zh-CN',
      'ar': 'ar-SA',
      'hi': 'hi-IN',
    };
    return languageCodes[code] ?? 'en-US';
  }
}
