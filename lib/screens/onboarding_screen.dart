import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_theme.dart';
import 'auth_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _iconController;
  int _currentIndex = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Smart Object Detection',
      description:
          'Point your camera at any object and get instant AI-powered recognition with 95%+ accuracy',
      icon: Icons.smart_toy_rounded,
      color: AppTheme.primaryColor,
      gradient: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
    ),
    OnboardingPage(
      title: 'Real-time Recognition',
      description:
          'Get instant results as you point your camera at objects with lightning-fast processing',
      icon: Icons.speed_rounded,
      color: AppTheme.successColor,
      gradient: [AppTheme.successColor, AppTheme.successColor.withOpacity(0.7)],
    ),
    OnboardingPage(
      title: 'Multi-language Support',
      description:
          'Translate and learn object names in 50+ languages with voice pronunciation',
      icon: Icons.translate_rounded,
      color: AppTheme.secondaryColor,
      gradient: [
        AppTheme.secondaryColor,
        AppTheme.secondaryColor.withOpacity(0.7)
      ],
    ),
    OnboardingPage(
      title: 'Educational Insights',
      description:
          'Discover fascinating facts and learn about the world around you with detailed information',
      icon: Icons.school_rounded,
      color: AppTheme.warningColor,
      gradient: [AppTheme.warningColor, AppTheme.warningColor.withOpacity(0.7)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _iconController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Start initial animations
    _fadeController.forward();
    _slideController.forward();
    _iconController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentPage = _pages[_currentIndex];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              currentPage.color.withOpacity(0.05),
              theme.colorScheme.surface,
              currentPage.color.withOpacity(0.02),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              _buildTopBar(theme),

              // Page Content
              Expanded(child: _buildPageView(theme)),

              // Page Indicators
              _buildPageIndicators(theme),

              const SizedBox(height: 32),

              // Navigation Buttons
              _buildNavigationButtons(theme),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo/Title
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.visibility_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Vision Pro',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),

          // Skip Button
          if (_currentIndex < _pages.length - 1)
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _completeOnboarding();
              },
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurfaceVariant,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'Skip',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    ).animate().slideY(begin: -0.3).fadeIn();
  }

  Widget _buildPageView(ThemeData theme) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        HapticFeedback.lightImpact();
        setState(() => _currentIndex = index);

        // Restart animations for new page
        _iconController.reset();
        _iconController.forward();
      },
      itemCount: _pages.length,
      itemBuilder: (context, index) {
        final page = _pages[index];
        final isActive = index == _currentIndex;

        return AnimatedOpacity(
          opacity: isActive ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Container
                _buildIconContainer(page, theme, isActive),

                const SizedBox(height: 48),

                // Title
                Text(
                  page.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(target: isActive ? 1 : 0)
                    .slideY(begin: 0.3)
                    .fadeIn(delay: 200.ms),

                const SizedBox(height: 20),

                // Description
                Text(
                  page.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(target: isActive ? 1 : 0)
                    .slideY(begin: 0.3)
                    .fadeIn(delay: 400.ms),

                const SizedBox(height: 40),

                // Feature Highlights
                _buildFeatureHighlights(page, theme, isActive),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconContainer(
      OnboardingPage page, ThemeData theme, bool isActive) {
    return AnimatedBuilder(
      animation: _iconController,
      builder: (context, child) {
        return Transform.scale(
          scale: isActive ? (0.8 + (_iconController.value * 0.2)) : 0.8,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: page.gradient,
              ),
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: page.color.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: page.color.withOpacity(0.1),
                  blurRadius: 40,
                  spreadRadius: 10,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Transform.rotate(
              angle: _iconController.value * 0.1,
              child: Icon(
                page.icon,
                size: 70,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    ).animate(target: isActive ? 1 : 0).scale().shimmer(duration: 2000.ms);
  }

  Widget _buildFeatureHighlights(
      OnboardingPage page, ThemeData theme, bool isActive) {
    final features = _getPageFeatures(page);

    return Column(
      children: features.asMap().entries.map((entry) {
        final index = entry.key;
        final feature = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: page.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: page.color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                feature.icon,
                color: page.color,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                feature.text,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: page.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        )
            .animate(target: isActive ? 1 : 0)
            .slideX(
                begin: 0.3, delay: Duration(milliseconds: 600 + (index * 100)))
            .fadeIn(delay: Duration(milliseconds: 600 + (index * 100)));
      }).toList(),
    );
  }

  List<FeatureHighlight> _getPageFeatures(OnboardingPage page) {
    switch (_pages.indexOf(page)) {
      case 0:
        return [
          FeatureHighlight(
              icon: Icons.precision_manufacturing_rounded,
              text: '95%+ Accuracy'),
          FeatureHighlight(
              icon: Icons.flash_on_rounded, text: 'Instant Results'),
        ];
      case 1:
        return [
          FeatureHighlight(
              icon: Icons.timelapse_rounded, text: 'Real-time Processing'),
          FeatureHighlight(
              icon: Icons.offline_bolt_rounded, text: 'Works Offline'),
        ];
      case 2:
        return [
          FeatureHighlight(icon: Icons.language_rounded, text: '50+ Languages'),
          FeatureHighlight(
              icon: Icons.record_voice_over_rounded, text: 'Voice Support'),
        ];
      case 3:
        return [
          FeatureHighlight(
              icon: Icons.auto_stories_rounded, text: 'Rich Information'),
          FeatureHighlight(
              icon: Icons.psychology_rounded, text: 'Learn & Discover'),
        ];
      default:
        return [];
    }
  }

  Widget _buildPageIndicators(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) {
          final isActive = _currentIndex == index;
          final page = _pages[index];

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isActive ? 32 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: isActive ? LinearGradient(colors: page.gradient) : null,
              color:
                  !isActive ? theme.colorScheme.outline.withOpacity(0.3) : null,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        },
      ),
    ).animate().slideY(begin: 0.3).fadeIn(delay: 800.ms);
  }

  Widget _buildNavigationButtons(ThemeData theme) {
    final currentPage = _pages[_currentIndex];
    final isLastPage = _currentIndex == _pages.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          // Back Button
          if (_currentIndex > 0)
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: TextButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                label: Text(
                  'Back',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

          const Spacer(),

          // Next/Get Started Button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: currentPage.gradient),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: currentPage.color.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                if (isLastPage) {
                  _completeOnboarding();
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              icon: Icon(
                isLastPage
                    ? Icons.rocket_launch_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Colors.white,
              ),
              label: Text(
                isLastPage ? 'Get Started' : 'Next',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shadowColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3).fadeIn(delay: 1000.ms);
  }

  void _completeOnboarding() async {
    try {
      HapticFeedback.mediumImpact();

      // Show completion feedback
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
              const Text(
                'Welcome to AI Vision Pro!',
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
          duration: const Duration(seconds: 2),
        ),
      );

      // Mark onboarding as completed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);

      if (mounted) {
        // Add a small delay for better UX
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate directly to auth screen since onboarding is now complete
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      }
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      }
    }
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}

class FeatureHighlight {
  final IconData icon;
  final String text;

  FeatureHighlight({
    required this.icon,
    required this.text,
  });
}
