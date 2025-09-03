// screens/camera_screen.dart - ENHANCED VERSION

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../models/camera_state.dart';
import '../providers/ads_provider.dart';
import '../providers/camera_provider.dart';
import '../providers/challenge_provider.dart';
import '../providers/detection_provider.dart';
import '../providers/premium_provider.dart';
import '../providers/real_time_detection_provider.dart';
import '../providers/analytics_provider.dart';
import '../config/app_theme.dart';
import '../utils/camera_mode.dart';
import '../utils/sound_manager.dart';
import '../widgets/camera_settings_sheet.dart';
import '../widgets/grid_painter.dart';
import '../widgets/tutorial_overlay.dart';
import '../widgets/detection_result_overlay.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _focusController;
  late AnimationController _overlayController;
  late AnimationController _modeTransitionController;
  late AnimationController _captureAnimationController;
  late AnimationController _uiAnimationController;

  // Timers
  Timer? _autoFocusTimer;
  Timer? _realTimeDetectionTimer;
  Timer? _captureTimer;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  // State Variables
  bool _isProcessing = false;
  bool _isRealTimeMode = false;
  bool _showTutorial = false;
  bool _isFlashOn = false;
  bool _showGrid = false;
  bool _showLevel = false;
  bool _isBatchMode = false;
  bool _isTimerMode = false;
  int _timerSeconds = 3;
  int _batchCount = 0;
  final int _maxBatchImages = 5;
  bool _hasSensorsError = false;

  Offset? _focusPoint;
  CameraMode _currentMode = CameraMode.object;

  // Device orientation tracking
  double _deviceTilt = 0.0;
  bool _isDeviceLevel = false;

  // Voice control
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;

  // Capture feedback
  bool _showCaptureFlash = false;

  Map<String, dynamic>? _challengeArgs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeControllers();
    _initializeVoiceControl();
    _initializeSensors();
    _checkFirstTime();

    // Initialize camera after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCamera();
      _checkChallengeArgs();
    });
  }

  void _checkChallengeArgs() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['challenge'] == true) {
      _challengeArgs = args;
      if (args['challengeType'] == 'plants') {
        setState(() => _currentMode = CameraMode.plant);
        _tts.speak("Challenge started: Scan 3 different plants");
        _showChallengeSnackBar();
      }
    }
  }

  void _showChallengeSnackBar() {
    final challengeState = ref.read(challengeProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${challengeState.description}\nProgress: ${challengeState.progress}/${challengeState.total}',
        ),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _initializeControllers() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _focusController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _modeTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _captureAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _uiAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  void _initializeVoiceControl() async {
    try {
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.8);
      await _tts.setVolume(0.8);
      await _tts.setPitch(1.0);
    } catch (e) {
      debugPrint('TTS initialization failed: $e');
    }
  }

  void _initializeSensors() {
    try {
      _accelerometerSubscription = accelerometerEvents.listen(
        (event) {
          if (!_hasSensorsError) {
            final tilt = math.atan2(event.x, event.y) * 180 / math.pi;
            if (mounted) {
              setState(() {
                _deviceTilt = tilt;
                _isDeviceLevel = tilt.abs() < 5;
              });
            }
          }
        },
        onError: (error) {
          debugPrint('Accelerometer error: $error');
          setState(() => _hasSensorsError = true);
        },
      );
    } catch (e) {
      debugPrint('Failed to initialize sensors: $e');
      setState(() => _hasSensorsError = true);
    }
  }

  void _initializeCamera() {
    Future.microtask(() async {
      if (mounted) {
        final cameraNotifier = ref.read(cameraProvider.notifier);
        await cameraNotifier.initializeCamera();
      }
    });
  }

  void _checkFirstTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tutorialShown = prefs.getBool('camera_tutorial_shown') ?? false;
      if (!tutorialShown && mounted) {
        setState(() => _showTutorial = true);
        prefs.setBool('camera_tutorial_shown', true);
      }
    } catch (e) {
      debugPrint('Error checking first time: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final cameraState = ref.read(cameraProvider);
    if (!cameraState.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _stopRealTimeDetection();
    } else if (state == AppLifecycleState.resumed) {
      if (_isRealTimeMode) {
        _startRealTimeDetection();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _focusController.dispose();
    _overlayController.dispose();
    _modeTransitionController.dispose();
    _captureAnimationController.dispose();
    _uiAnimationController.dispose();
    _autoFocusTimer?.cancel();
    _realTimeDetectionTimer?.cancel();
    _captureTimer?.cancel();
    _accelerometerSubscription?.cancel();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraProvider);
    final isPremium = ref.watch(premiumProvider).isPremium;
    final realTimeDetections = ref.watch(realTimeDetectionProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          _buildCameraPreview(cameraState),

          // Real-time Detection Overlay
          if (_isRealTimeMode && isPremium && realTimeDetections.isNotEmpty)
            DetectionResultOverlay(
              detections: realTimeDetections,
              mode: _currentMode,
              isRealTime: true,
            ),

          // Grid Lines
          if (_showGrid && cameraState.isInitialized) _buildGridOverlay(),

          // Level Indicator
          if (_showLevel && isPremium && !_hasSensorsError)
            _buildLevelIndicator(),

          // Focus Point Indicator
          if (_focusPoint != null) _buildFocusIndicator(),

          // UI Overlay
          _buildUIOverlay(isPremium),

          // Tutorial Overlay
          if (_showTutorial)
            TutorialOverlay(
              mode: _currentMode,
              onComplete: () => setState(() => _showTutorial = false),
            ),

          // Processing Indicator
          if (_isProcessing) _buildProcessingOverlay(),

          // Timer Countdown
          if (_isTimerMode && _captureTimer != null) _buildTimerCountdown(),

          // Capture Flash Effect
          if (_showCaptureFlash) _buildCaptureFlash(),

          // Batch Mode Indicator
          if (_isBatchMode) _buildBatchModeIndicator(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(CameraState cameraState) {
    if (cameraState.status == CameraStatus.error) {
      return _buildErrorState(cameraState.errorMessage ?? 'Camera error');
    }

    if (!cameraState.isInitialized) {
      return _buildLoadingState();
    }

    return GestureDetector(
      onTapUp: _handleFocusTap,
      onDoubleTap: _switchCamera,
      onLongPress: _showQuickSettings,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: cameraState.controller!.value.previewSize!.height,
            height: cameraState.controller!.value.previewSize!.width,
            child: CameraPreview(cameraState.controller!),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.black,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: AppTheme.primaryColor,
                size: 60,
              ),
            ).animate().scale().then().shimmer(duration: 2000.ms),
            const SizedBox(height: 32),
            Text(
              'Initializing Camera...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Setting up AI vision capabilities',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.errorColor.withOpacity(0.1),
            Colors.black,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppTheme.errorColor,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Camera Error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.getElevationShadow(context, 4),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _initializeCamera();
                  },
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridOverlay() {
    return Positioned.fill(
      child: CustomPaint(
        painter: GridPainter(
          lineColor: AppTheme.primaryColor.withOpacity(0.4),
          strokeWidth: 1.5,
        ),
      ),
    );
  }

  Widget _buildLevelIndicator() {
    return Positioned(
      top: 120,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _isDeviceLevel
                ? AppTheme.successColor.withOpacity(0.9)
                : Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isDeviceLevel
                  ? AppTheme.successColor
                  : Colors.white.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: AppTheme.getElevationShadow(context, 4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isDeviceLevel
                    ? Icons.check_circle_rounded
                    : Icons.straighten_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                _isDeviceLevel
                    ? 'Perfect Level'
                    : '${_deviceTilt.toStringAsFixed(1)}°',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      )
          .animate(target: _isDeviceLevel ? 1 : 0)
          .tint(color: AppTheme.successColor),
    );
  }

  Widget _buildFocusIndicator() {
    final modeColor = _getModeColor();

    return Positioned(
      left: _focusPoint!.dx - 50,
      top: _focusPoint!.dy - 50,
      child: AnimatedBuilder(
        animation: _focusController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_focusController.value * 0.2),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(1.0 - _focusController.value),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                margin: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: modeColor.withOpacity(1.0 - _focusController.value),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: modeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUIOverlay(bool isPremium) {
    return AnimatedBuilder(
      animation: _uiAnimationController,
      builder: (context, child) {
        return SafeArea(
          child: Column(
            children: [
              Transform.translate(
                offset: Offset(0, -50 * (1 - _uiAnimationController.value)),
                child: Opacity(
                  opacity: _uiAnimationController.value,
                  child: _buildTopBar(isPremium),
                ),
              ),
              const Spacer(),
              Transform.translate(
                offset: Offset(0, 50 * (1 - _uiAnimationController.value)),
                child: Opacity(
                  opacity: _uiAnimationController.value,
                  child: _buildBottomControls(isPremium),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(bool isPremium) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildTopBarButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 12),
          _buildTopBarButton(
            icon: _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
            isActive: _isFlashOn,
            onPressed: _toggleFlash,
          ),
          const Spacer(),
          _buildModeSelector(),
          const Spacer(),
          if (isPremium)
            _buildTopBarButton(
              icon: Icons.grid_on_rounded,
              isActive: _showGrid,
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _showGrid = !_showGrid);
              },
            ),
          const SizedBox(width: 12),
          _buildTopBarButton(
            icon: Icons.settings_rounded,
            onPressed: _showCameraSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildTopBarButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive
              ? _getModeColor().withOpacity(0.9)
              : Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? _getModeColor() : Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: AppTheme.getElevationShadow(context, 4),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showModeSelection();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getModeColor(),
              _getModeColor().withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _getModeColor().withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getModeIcon(_currentMode),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              _getModeLabel(_currentMode),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(bool isPremium) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPremium) ...[
            _buildPremiumControls(),
            const SizedBox(height: 24),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.photo_library_rounded,
                onPressed: _pickFromGallery,
                size: 56,
              ),
              if (isPremium)
                _buildControlButton(
                  icon:
                      _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  onPressed: _toggleVoiceControl,
                  size: 56,
                  isActive: _isListening,
                  activeColor: AppTheme.errorColor,
                ),
              _buildCaptureButton(),
              if (isPremium)
                _buildControlButton(
                  icon: Icons.burst_mode_rounded,
                  onPressed: _toggleBatchMode,
                  size: 56,
                  isActive: _isBatchMode,
                ),
              _buildControlButton(
                icon: Icons.flip_camera_ios_rounded,
                onPressed: _switchCamera,
                size: 56,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPremiumControlChip(
          icon: _isRealTimeMode
              ? Icons.visibility_rounded
              : Icons.visibility_off_rounded,
          label: 'Real-time',
          isActive: _isRealTimeMode,
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _isRealTimeMode = !_isRealTimeMode);
            if (_isRealTimeMode) {
              _startRealTimeDetection();
            } else {
              _stopRealTimeDetection();
            }
          },
        ),
        const SizedBox(width: 16),
        if (!_hasSensorsError)
          _buildPremiumControlChip(
            icon: Icons.straighten_rounded,
            label: 'Level',
            isActive: _showLevel,
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _showLevel = !_showLevel);
            },
          ),
      ],
    );
  }

  Widget _buildPremiumControlChip({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? _getModeColor().withOpacity(0.9)
              : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? _getModeColor() : Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: isActive ? AppTheme.getElevationShadow(context, 2) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 56,
    bool isActive = false,
    Color? activeColor,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isActive
              ? (activeColor ?? _getModeColor()).withOpacity(0.9)
              : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(
            color: isActive
                ? (activeColor ?? _getModeColor())
                : Colors.white.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: AppTheme.getElevationShadow(context, 4),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.4,
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _isProcessing
          ? null
          : () {
              HapticFeedback.mediumImpact();
              _capturePhoto();
            },
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: _getModeColor(),
                width: 4 + (_pulseController.value * 2),
              ),
              boxShadow: [
                BoxShadow(
                  color: _getModeColor().withOpacity(0.5),
                  blurRadius: 20 + (_pulseController.value * 10),
                  spreadRadius: _pulseController.value * 8,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _captureAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 - (_captureAnimationController.value * 0.1),
                  child: Icon(
                    _getCaptureIcon(),
                    color: _getModeColor(),
                    size: 36,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    final modeColor = _getModeColor();

    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: modeColor.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: modeColor.withOpacity(0.3),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: modeColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(modeColor),
                      strokeWidth: 4,
                    ),
                  ),
                  Icon(
                    _getModeIcon(_currentMode),
                    color: modeColor,
                    size: 45,
                  ),
                ],
              ),
            ).animate().scale().then().shimmer(duration: 1500.ms),
            const SizedBox(height: 40),
            Text(
              _getProcessingText(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'AI is analyzing your ${_currentMode.name}...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 250,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(modeColor),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Please wait...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.5),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerCountdown() {
    final modeColor = _getModeColor();

    return Container(
      color: Colors.black.withOpacity(0.95),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: modeColor,
                  width: 6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: modeColor.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$_timerSeconds',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: modeColor,
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ).animate().scale(duration: 1000.ms),
            const SizedBox(height: 40),
            Text(
              'Get ready!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 60),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.errorColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.getElevationShadow(context, 4),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _cancelTimer();
                },
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                ),
                label: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureFlash() {
    return AnimatedOpacity(
      opacity: _showCaptureFlash ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildBatchModeIndicator() {
    final modeColor = _getModeColor();

    return Positioned(
      top: 180,
      right: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              modeColor,
              modeColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: AppTheme.getElevationShadow(context, 4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'BATCH MODE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '$_batchCount/$_maxBatchImages',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ).animate().slideX().fadeIn(),
    );
  }

  // Event handlers and helper methods
  void _handleFocusTap(TapUpDetails details) async {
    final cameraState = ref.read(cameraProvider);
    if (!cameraState.isInitialized) return;

    setState(() => _focusPoint = details.localPosition);

    _focusController.forward().then((_) {
      _focusController.reverse().then((_) {
        if (mounted) {
          setState(() => _focusPoint = null);
        }
      });
    });

    try {
      final cameraNotifier = ref.read(cameraProvider.notifier);
      await cameraNotifier.setFocusPoint(details.localPosition);
      HapticFeedback.lightImpact();
      await _tts.speak("Focus set");
    } catch (e) {
      debugPrint('Focus error: $e');
    }
  }

  void _switchCamera() async {
    try {
      HapticFeedback.lightImpact();
      final cameraNotifier = ref.read(cameraProvider.notifier);
      await cameraNotifier.switchCamera();
      await _tts.speak("Camera switched");
    } catch (e) {
      _showErrorSnackBar('Failed to switch camera: $e');
    }
  }

  void _capturePhoto() async {
    if (_isProcessing) return;

    if (_isTimerMode) {
      _startCaptureTimer();
      return;
    }

    await _performCapture();
  }

  void _startCaptureTimer() {
    setState(() => _timerSeconds = 3);

    _captureTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _timerSeconds--);
        _tts.speak(_timerSeconds.toString());
        HapticFeedback.lightImpact();

        if (_timerSeconds <= 0) {
          timer.cancel();
          _captureTimer = null;
          _performCapture();
        }
      } else {
        timer.cancel();
        _captureTimer = null;
      }
    });
  }

  Future<void> _performCapture() async {
    if (!mounted) return;

    setState(() => _isProcessing = true);

    // Capture animation and feedback
    _captureAnimationController.forward().then((_) {
      _captureAnimationController.reverse();
    });

    setState(() => _showCaptureFlash = true);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _showCaptureFlash = false);
      }
    });

    HapticFeedback.mediumImpact();
    SoundManager.playShutter();

    try {
      final cameraNotifier = ref.read(cameraProvider.notifier);
      final detectionNotifier = ref.read(detectionProvider.notifier);

      final imageFile = await cameraNotifier.takePicture();
      if (imageFile != null) {
        await detectionNotifier.processImage(
          File(imageFile.path),
          mode: _currentMode,
        );

        ref.read(analyticsProvider.notifier).trackDetection(_currentMode, 1);

        if (_isBatchMode) {
          setState(() => _batchCount++);

          if (_batchCount >= _maxBatchImages) {
            setState(() {
              _isBatchMode = false;
              _batchCount = 0;
            });
            await _tts.speak("Batch capture complete");
          } else {
            await _tts.speak("Image $_batchCount captured");
          }
        }

        if (mounted) {
          final isPremium = ref.read(premiumProvider).isPremium;

          // Show interstitial ad before navigating to results
          if (!isPremium) {
            ref.read(adsProvider.notifier).showInterstitialAd(
              onAdDismissed: () {
                if (mounted) {
                  Navigator.pushNamed(context, '/result');
                }
              },
            );
          } else {
            Navigator.pushNamed(context, '/result');
          }
        }
      }

      // In _performCapture (add to the try block after processing image)
      final detectionResult = ref.read(detectionProvider).currentResult;
      if (detectionResult != null && _challengeArgs != null) {
        if (_currentMode == CameraMode.plant &&
            detectionResult.objects.isNotEmpty) {
          // Assume first object is the detected plant; adjust based on your model
          if (detectionResult.objects.first.type?.toLowerCase() == 'plant') {
            final notifier = ref.read(challengeProvider.notifier);
            final newProgress = notifier.incrementProgress();

            _tts.speak(
                "Plant detected. Progress: $newProgress/${_challengeArgs!['challengeTarget']}");

            if (newProgress >= _challengeArgs!['challengeTarget']) {
              notifier.completeChallenge();
              _tts.speak(
                  "Challenge completed! You've earned ${_challengeArgs!['reward']}");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Challenge Completed! Reward: ${_challengeArgs!['reward']}')),
              );
              // Optionally pop back to HomeScreen
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Progress: $newProgress/${_challengeArgs!['challengeTarget']}')),
              );
            }
          } else {
            _tts.speak("No plant detected. Try again.");
          }
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to capture image: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _cancelTimer() {
    _captureTimer?.cancel();
    _captureTimer = null;
    if (mounted) {
      setState(() => _timerSeconds = 3);
    }
  }

  void _pickFromGallery() async {
    try {
      HapticFeedback.lightImpact();
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null && mounted) {
        setState(() => _isProcessing = true);

        final detectionNotifier = ref.read(detectionProvider.notifier);
        await detectionNotifier.processImage(
          File(image.path),
          mode: _currentMode,
        );

        ref.read(analyticsProvider.notifier).trackDetection(_currentMode, 0);

        if (mounted) {
          Navigator.pushNamed(context, '/result');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _toggleVoiceControl() async {
    HapticFeedback.lightImpact();

    if (_isListening) {
      setState(() => _isListening = false);
      await _tts.speak("Voice commands disabled");
    } else {
      setState(() => _isListening = true);
      await _tts.speak(
          "Voice commands enabled. Say capture, switch camera, or toggle flash");

      if (mounted) {
        _showVoiceCommandsSnackBar();
      }
    }
  }

  void _showVoiceCommandsSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.mic_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Voice commands: "Capture", "Switch camera", "Toggle flash"',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: _getModeColor(),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _toggleBatchMode() {
    if (!ref.read(premiumProvider).isPremium) {
      _showPremiumRequired();
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _isBatchMode = !_isBatchMode;
      if (!_isBatchMode) {
        _batchCount = 0;
      }
    });

    final message = _isBatchMode
        ? "Batch mode enabled. Capture up to $_maxBatchImages images."
        : "Batch mode disabled";

    _tts.speak(message);
  }

  void _toggleFlash() async {
    try {
      HapticFeedback.lightImpact();
      final cameraNotifier = ref.read(cameraProvider.notifier);
      await cameraNotifier.toggleFlash();

      final flashState = ref.read(cameraProvider).isFlashOn;
      setState(() => _isFlashOn = flashState);

      await _tts.speak(flashState ? "Flash on" : "Flash off");
    } catch (e) {
      _showErrorSnackBar('Failed to toggle flash: $e');
    }
  }

  void _startRealTimeDetection() {
    if (!ref.read(premiumProvider).isPremium) {
      _showPremiumRequired();
      return;
    }

    _realTimeDetectionTimer = Timer.periodic(
      const Duration(milliseconds: 800),
      (timer) async {
        if (!_isRealTimeMode || _isProcessing || !mounted) {
          return;
        }

        try {
          final cameraState = ref.read(cameraProvider);
          if (!cameraState.isInitialized) return;

          final cameraNotifier = ref.read(cameraProvider.notifier);
          final image = await cameraNotifier.takePicture();

          if (image != null && mounted) {
            ref.read(realTimeDetectionProvider.notifier).processFrame(
                  File(image.path),
                  _currentMode,
                );
          }
        } catch (e) {
          debugPrint('Real-time detection error: $e');
        }
      },
    );
  }

  void _stopRealTimeDetection() {
    _realTimeDetectionTimer?.cancel();
    _realTimeDetectionTimer = null;
    if (mounted) {
      ref.read(realTimeDetectionProvider.notifier).clearDetections();
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

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
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _showCameraSettings() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CameraSettingsSheet(),
    );
  }

  void _showModeSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // Important: allows custom height
      builder: (context) => Container(
        // Use constraints to limit height and make it responsive
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height * 0.8, // Max 80% of screen
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
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
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16), // Reduced from 24
              child: Text(
                'Detection Mode',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            // Mode grid - Make it flexible and scrollable
            Flexible(
              child: GridView.builder(
                shrinkWrap: true, // Important: allows grid to size itself
                padding: const EdgeInsets.symmetric(
                    horizontal: 16), // Reduced padding
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio:
                      _getAspectRatio(context), // Dynamic aspect ratio
                  crossAxisSpacing: 12, // Reduced spacing
                  mainAxisSpacing: 12,
                ),
                itemCount: CameraMode.values.length,
                itemBuilder: (context, index) {
                  final mode = CameraMode.values[index];
                  final isSelected = mode == _currentMode;
                  final isPremiumMode = _isPremiumMode(mode);
                  final isPremium = ref.read(premiumProvider).isPremium;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();

                      if (isPremiumMode && !isPremium) {
                        Navigator.pop(context);
                        _showPremiumRequired(mode);
                        return;
                      }

                      setState(() => _currentMode = mode);
                      Navigator.pop(context);
                      _onModeChanged(mode);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  _getModeColor(mode),
                                  _getModeColor(mode).withOpacity(0.8),
                                ],
                              )
                            : null,
                        color:
                            !isSelected ? Colors.white.withOpacity(0.1) : null,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? _getModeColor(mode)
                              : Colors.white.withOpacity(0.3),
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _getModeColor(mode).withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getModeIcon(mode),
                                  color: Colors.white,
                                  size: _getIconSize(
                                      context), // Dynamic icon size
                                ),
                                SizedBox(
                                    height: _getSpacing(
                                        context)), // Dynamic spacing
                                Text(
                                  _getModeLabel(mode),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: _getFontSize(
                                            context), // Dynamic font size
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          if (isPremiumMode && !isPremium)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppTheme.premiumGold,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.diamond_rounded,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(
                height: _getBottomSpacing(context)), // Dynamic bottom spacing
          ],
        ),
      ),
    );
  }

// Helper methods for responsive sizing
  double _getAspectRatio(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Adjust aspect ratio based on screen height
    if (screenHeight < 600) return 1.8; // Taller items on very small screens
    if (screenHeight < 700) return 1.6; // Medium adjustment
    return 1.5; // Default for larger screens
  }

  double _getIconSize(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight < 600) return 24;
    if (screenHeight < 700) return 26;
    return 28;
  }

  double _getSpacing(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight < 600) return 4;
    if (screenHeight < 700) return 6;
    return 8;
  }

  double _getFontSize(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight < 600) return 12;
    if (screenHeight < 700) return 13;
    return 14;
  }

  double _getBottomSpacing(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight < 600) return 16;
    return 24;
  }

  void _showQuickSettings() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
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
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Quick Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            // Settings list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildQuickSettingTile(
                    icon: Icons.grid_on_rounded,
                    title: 'Grid Lines',
                    value: _showGrid,
                    onChanged: (value) => setState(() => _showGrid = value),
                  ),
                  if (!_hasSensorsError)
                    _buildQuickSettingTile(
                      icon: Icons.straighten_rounded,
                      title: 'Level Indicator',
                      value: _showLevel,
                      onChanged: (value) => setState(() => _showLevel = value),
                      isPremium: true,
                    ),
                  _buildQuickSettingTile(
                    icon: Icons.timer_rounded,
                    title: 'Timer Mode',
                    value: _isTimerMode,
                    onChanged: (value) => setState(() => _isTimerMode = value),
                  ),
                  _buildQuickSettingTile(
                    icon: Icons.burst_mode_rounded,
                    title: 'Batch Mode',
                    value: _isBatchMode,
                    onChanged: (value) => _toggleBatchMode(),
                    isPremium: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSettingTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
    bool isPremium = false,
  }) {
    final userIsPremium = ref.read(premiumProvider).isPremium;
    final isEnabled = !isPremium || userIsPremium;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isEnabled ? Colors.white : Colors.grey,
          size: 24,
        ),
        title: Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isEnabled ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (isPremium && !userIsPremium) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.diamond_rounded,
                color: AppTheme.premiumGold,
                size: 16,
              ),
            ],
          ],
        ),
        trailing: Switch(
          value: isEnabled ? value : false,
          onChanged: isEnabled
              ? (newValue) {
                  HapticFeedback.lightImpact();
                  onChanged(newValue);
                }
              : (value) => _showPremiumRequired(),
          thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return _getModeColor(); // Active thumb color
            }
            return Colors.grey.shade400; // Inactive thumb color
          }),
          trackColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return _getModeColor().withOpacity(0.3); // Active track color
            }
            return Colors.grey.shade600; // Inactive track color
          }),
        ),
        onTap: isEnabled
            ? () {
                HapticFeedback.lightImpact();
                onChanged(!value);
              }
            : () => _showPremiumRequired(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _onModeChanged(CameraMode newMode) {
    _modeTransitionController.forward().then((_) {
      _modeTransitionController.reverse();
    });

    if (_isRealTimeMode) {
      _stopRealTimeDetection();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _startRealTimeDetection();
        }
      });
    }

    _tts.speak("${_getModeLabel(newMode)} mode selected");
  }

  void _showPremiumRequired([CameraMode? mode]) {
    final modeText = mode != null ? ' for ${_getModeLabel(mode)} mode' : '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.diamond_rounded,
              color: AppTheme.premiumGold,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Premium Required',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        content: Text(
          'This feature$modeText requires a premium subscription. Upgrade now to unlock advanced AI capabilities.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Later',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
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
      ),
    );
  }

  // Helper methods
  bool _isPremiumMode(CameraMode mode) {
    return [
      CameraMode.landmark,
      CameraMode.plant,
      CameraMode.animal,
      CameraMode.food,
      CameraMode.document,
    ].contains(mode);
  }

  Color _getModeColor([CameraMode? mode]) {
    final targetMode = mode ?? _currentMode;
    switch (targetMode) {
      case CameraMode.object:
        return AppTheme.primaryColor;
      case CameraMode.text:
        return AppTheme.successColor;
      case CameraMode.barcode:
        return AppTheme.secondaryColor;
      case CameraMode.landmark:
        return AppTheme.warningColor;
      case CameraMode.plant:
        return AppTheme.successColor.withOpacity(0.8);
      case CameraMode.animal:
        return const Color(0xFF8D6E63); // Brown
      case CameraMode.food:
        return AppTheme.errorColor;
      case CameraMode.document:
        return const Color(0xFF3F51B5); // Indigo
    }
  }

  IconData _getModeIcon(CameraMode mode) {
    switch (mode) {
      case CameraMode.object:
        return Icons.category_rounded;
      case CameraMode.text:
        return Icons.text_fields_rounded;
      case CameraMode.barcode:
        return Icons.qr_code_rounded;
      case CameraMode.landmark:
        return Icons.location_city_rounded;
      case CameraMode.plant:
        return Icons.local_florist_rounded;
      case CameraMode.animal:
        return Icons.pets_rounded;
      case CameraMode.food:
        return Icons.restaurant_rounded;
      case CameraMode.document:
        return Icons.description_rounded;
    }
  }

  String _getModeLabel(CameraMode mode) {
    switch (mode) {
      case CameraMode.object:
        return 'Objects';
      case CameraMode.text:
        return 'Text';
      case CameraMode.barcode:
        return 'Barcode';
      case CameraMode.landmark:
        return 'Landmarks';
      case CameraMode.plant:
        return 'Plants';
      case CameraMode.animal:
        return 'Animals';
      case CameraMode.food:
        return 'Food';
      case CameraMode.document:
        return 'Documents';
    }
  }

  IconData _getCaptureIcon() {
    switch (_currentMode) {
      case CameraMode.text:
        return Icons.text_format_rounded;
      case CameraMode.barcode:
        return Icons.qr_code_scanner_rounded;
      case CameraMode.document:
        return Icons.document_scanner_rounded;
      default:
        return Icons.camera_rounded;
    }
  }

  String _getProcessingText() {
    switch (_currentMode) {
      case CameraMode.object:
        return 'Identifying Objects';
      case CameraMode.text:
        return 'Extracting Text';
      case CameraMode.barcode:
        return 'Scanning Code';
      case CameraMode.landmark:
        return 'Recognizing Landmark';
      case CameraMode.plant:
        return 'Identifying Plant';
      case CameraMode.animal:
        return 'Recognizing Animal';
      case CameraMode.food:
        return 'Analyzing Food';
      case CameraMode.document:
        return 'Processing Document';
    }
  }
}
