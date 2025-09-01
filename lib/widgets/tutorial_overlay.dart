// widgets/tutorial_overlay.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/camera_mode.dart';

class TutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final CameraMode? mode;

  const TutorialOverlay({
    super.key,
    required this.onComplete,
    this.mode,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  late List<TutorialStep> _steps;

  @override
  void initState() {
    super.initState();
    _initializeSteps();
  }

  void _initializeSteps() {
    _steps = [
      TutorialStep(
        title: 'Welcome to AI Vision Pro',
        description: 'Discover the power of AI-powered image recognition',
        icon: Icons.camera_alt,
        position: TutorialPosition.center,
        color: Colors.blue,
      ),
      TutorialStep(
        title: 'Choose Detection Mode',
        description:
            'Select from 8 different detection modes including objects, text, barcodes, and more',
        icon: Icons.tune,
        position: TutorialPosition.top,
        color: Colors.purple,
      ),
      TutorialStep(
        title: 'Tap to Focus',
        description:
            'Tap anywhere on the screen to focus the camera on that point',
        icon: Icons.center_focus_strong,
        position: TutorialPosition.center,
        color: Colors.green,
      ),
      TutorialStep(
        title: 'Capture or Import',
        description:
            'Take a photo with the camera button or import from your gallery',
        icon: Icons.photo_camera,
        position: TutorialPosition.bottom,
        color: Colors.orange,
      ),
      TutorialStep(
        title: 'Real-time Detection',
        description:
            'Premium users can enable real-time detection for instant results as you move the camera',
        icon: Icons.speed,
        position: TutorialPosition.center,
        isPremiumFeature: true,
        color: Colors.amber,
      ),
      TutorialStep(
        title: 'Voice Control',
        description:
            'Use voice commands like "capture", "switch camera", or "toggle flash" for hands-free control',
        icon: Icons.mic,
        position: TutorialPosition.bottom,
        isPremiumFeature: true,
        color: Colors.red,
      ),
      TutorialStep(
        title: 'Grid & Level Tools',
        description:
            'Enable grid lines and level indicator for perfect composition (Premium feature)',
        icon: Icons.grid_on,
        position: TutorialPosition.center,
        isPremiumFeature: true,
        color: Colors.teal,
      ),
    ];

    // Add mode-specific tutorial step if mode is provided
    if (widget.mode != null) {
      _steps.insert(2, _getModeSpecificStep(widget.mode!));
    }
  }

  TutorialStep _getModeSpecificStep(CameraMode mode) {
    switch (mode) {
      case CameraMode.object:
        return TutorialStep(
          title: 'Object Detection',
          description:
              'Point your camera at any object to identify it. Works with thousands of everyday items.',
          icon: Icons.category,
          position: TutorialPosition.center,
          color: Colors.blue,
        );
      case CameraMode.text:
        return TutorialStep(
          title: 'Text Recognition',
          description:
              'Extract text from images, documents, signs, and more with high accuracy.',
          icon: Icons.text_fields,
          position: TutorialPosition.center,
          color: Colors.green,
        );
      case CameraMode.barcode:
        return TutorialStep(
          title: 'Barcode Scanner',
          description:
              'Scan QR codes, barcodes, and other codes for instant information.',
          icon: Icons.qr_code,
          position: TutorialPosition.center,
          color: Colors.purple,
        );
      case CameraMode.landmark:
        return TutorialStep(
          title: 'Landmark Recognition',
          description:
              'Identify famous landmarks, buildings, and monuments around the world.',
          icon: Icons.location_city,
          position: TutorialPosition.center,
          isPremiumFeature: true,
          color: Colors.orange,
        );
      case CameraMode.plant:
        return TutorialStep(
          title: 'Plant Identification',
          description:
              'Discover plant species, flowers, and trees with detailed botanical information.',
          icon: Icons.local_florist,
          position: TutorialPosition.center,
          isPremiumFeature: true,
          color: Colors.teal,
        );
      case CameraMode.animal:
        return TutorialStep(
          title: 'Animal Recognition',
          description:
              'Identify animals, pets, and wildlife with species information.',
          icon: Icons.pets,
          position: TutorialPosition.center,
          isPremiumFeature: true,
          color: Colors.brown,
        );
      case CameraMode.food:
        return TutorialStep(
          title: 'Food Analysis',
          description:
              'Analyze food items, dishes, and ingredients with nutritional insights.',
          icon: Icons.restaurant,
          position: TutorialPosition.center,
          isPremiumFeature: true,
          color: Colors.red,
        );
      case CameraMode.document:
        return TutorialStep(
          title: 'Document Processing',
          description:
              'Process documents, receipts, and papers with advanced text extraction.',
          icon: Icons.description,
          position: TutorialPosition.center,
          isPremiumFeature: true,
          color: Colors.indigo,
        );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Tutorial',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'Step ${_currentStep + 1} of ${_steps.length}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: widget.onComplete,
                    icon: const Icon(Icons.close,
                        color: Colors.white70, size: 18),
                    label: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),

            // Progress Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (_currentStep + 1) / _steps.length,
                child: Container(
                  decoration: BoxDecoration(
                    color: _steps[_currentStep].color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ).animate().slideX(duration: 300.ms),

            // Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentStep = index);
                },
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return _buildTutorialStep(step, index);
                },
              ),
            ),

            // Navigation
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _steps.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: index == _currentStep ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: index == _currentStep
                              ? _steps[_currentStep].color
                              : Colors.white.withOpacity(0.3),
                        ),
                      )
                          .animate(target: index == _currentStep ? 1 : 0)
                          .scaleX(duration: 200.ms),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Navigation buttons
                  Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _previousStep,
                            icon: const Icon(Icons.arrow_back, size: 18),
                            label: const Text('Previous'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: BorderSide(
                                  color: Colors.white.withOpacity(0.3)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        )
                      else
                        const Expanded(child: SizedBox()),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _currentStep == _steps.length - 1
                              ? widget.onComplete
                              : _nextStep,
                          icon: Icon(
                            _currentStep == _steps.length - 1
                                ? Icons.check
                                : Icons.arrow_forward,
                            size: 18,
                          ),
                          label: Text(
                            _currentStep == _steps.length - 1
                                ? 'Get Started'
                                : 'Next',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _steps[_currentStep].color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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

  Widget _buildTutorialStep(TutorialStep step, int index) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 24, vertical: 16), // Reduced padding
        child: Column(
          mainAxisAlignment: _getMainAxisAlignment(step.position),
          children: [
            // Icon with animated background
            Container(
              width: 120, // Slightly smaller icon
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    step.color.withOpacity(0.3),
                    step.color.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(
                  color: step.color.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(14), // Adjusted margin
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step.color.withOpacity(0.2),
                ),
                child: Icon(
                  step.icon,
                  size: 42, // Slightly smaller icon
                  color: step.color,
                ),
              ),
            )
                .animate(delay: (index * 100).ms)
                .scale(
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 600.ms)
                .then()
                .shimmer(duration: 2000.ms, color: step.color.withOpacity(0.3)),

            const SizedBox(height: 32), // Reduced spacing

            // Premium badge
            if (step.isPremiumFeature)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.diamond, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'PREMIUM FEATURE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
                  .animate(delay: (200 + index * 100).ms)
                  .slideY(begin: -0.3, end: 0)
                  .fadeIn()
                  .then()
                  .shimmer(duration: 1500.ms),

            if (step.isPremiumFeature)
              const SizedBox(height: 20), // Reduced spacing

            // Title - with proper text wrapping
            SizedBox(
              width: double.infinity,
              child: Text(
                step.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible, // Allow text to wrap
                softWrap: true,
              ),
            )
                .animate(delay: (300 + index * 100).ms)
                .slideY(begin: 0.3, end: 0)
                .fadeIn(duration: 500.ms),

            const SizedBox(height: 16), // Reduced spacing

            // Description - with proper constraints
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width -
                    48, // Account for padding
              ),
              child: Text(
                step.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      height: 1.5, // Slightly reduced line height
                      fontSize: 15, // Slightly smaller font
                    ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            )
                .animate(delay: (400 + index * 100).ms)
                .slideY(begin: 0.3, end: 0)
                .fadeIn(duration: 500.ms),

            // Additional tips for specific steps
            if (index == 2) // Focus step
              Container(
                margin: const EdgeInsets.only(top: 20), // Reduced margin
                padding: const EdgeInsets.all(14), // Reduced padding
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.amber,
                      size: 18, // Smaller icon
                    ),
                    const SizedBox(width: 10), // Reduced spacing
                    Expanded(
                      child: Text(
                        'Pro Tip: Double-tap to switch cameras',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13, // Smaller font
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  .animate(delay: (600 + index * 100).ms)
                  .slideY(begin: 0.3, end: 0)
                  .fadeIn(),
          ],
        ),
      ),
    );
  }

  MainAxisAlignment _getMainAxisAlignment(TutorialPosition position) {
    switch (position) {
      case TutorialPosition.top:
        return MainAxisAlignment.start;
      case TutorialPosition.center:
        return MainAxisAlignment.center;
      case TutorialPosition.bottom:
        return MainAxisAlignment.end;
    }
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final TutorialPosition position;
  final bool isPremiumFeature;
  final Color color;

  TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.position,
    this.isPremiumFeature = false,
    required this.color,
  });
}

enum TutorialPosition {
  top,
  center,
  bottom,
}
