// providers/camera_provider.dart - FIXED VERSION

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../models/camera_state.dart';

class CameraNotifier extends StateNotifier<CameraState> {
  CameraNotifier(List<CameraDescription> cameras)
      : super(CameraState(cameras: cameras));

  Future<void> initializeCamera() async {
    if (state.cameras.isEmpty) {
      state = state.copyWith(
          status: CameraStatus.error, errorMessage: 'No cameras available');
      return;
    }

    // Avoid reinitializing if already initialized
    if (state.isInitialized) {
      return;
    }

    // FIXED: Use microtask to avoid modifying state during widget build
    await Future.microtask(() async {
      if (mounted) {
        state = state.copyWith(status: CameraStatus.initializing);
        await _prepareCamera();
      }
    });
  }

  Future<void> _prepareCamera() async {
    // Dispose existing controller if any
    if (state.controller != null) {
      try {
        await state.controller!.dispose();
      } catch (e) {
        debugPrint('Error disposing previous camera controller: $e');
      }
    }

    try {
      final controller = CameraController(
        state.cameras[state.selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      // Check if still mounted before updating state
      if (mounted) {
        state = state.copyWith(
          controller: controller,
          status: CameraStatus.initialized,
          errorMessage: null,
        );
      } else {
        // Dispose if widget was unmounted during initialization
        await controller.dispose();
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          status: CameraStatus.error,
          errorMessage: 'Failed to initialize camera: ${e.toString()}',
        );
      }
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> startStream() async {
    if (!state.isInitialized || state.status == CameraStatus.streaming) return;

    try {
      if (mounted) {
        state = state.copyWith(status: CameraStatus.streaming);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          status: CameraStatus.error,
          errorMessage: 'Failed to start camera stream: ${e.toString()}',
        );
      }
      debugPrint('Error starting camera stream: $e');
    }
  }

  Future<void> stopStream() async {
    if (!state.isInitialized) return;

    try {
      if (mounted) {
        state = state.copyWith(status: CameraStatus.initialized);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          status: CameraStatus.error,
          errorMessage: 'Failed to stop camera stream: ${e.toString()}',
        );
      }
      debugPrint('Error stopping camera stream: $e');
    }
  }

  Future<void> switchCamera() async {
    if (state.cameras.length <= 1) return;

    try {
      final newIndex = (state.selectedCameraIndex + 1) % state.cameras.length;

      if (mounted) {
        state = state.copyWith(selectedCameraIndex: newIndex);
        await _prepareCamera();

        if (state.status == CameraStatus.initialized && mounted) {
          await startStream();
        }
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          status: CameraStatus.error,
          errorMessage: 'Failed to switch camera: ${e.toString()}',
        );
      }
      debugPrint('Error switching camera: $e');
    }
  }

  Future<XFile?> takePicture() async {
    if (!state.isInitialized || state.controller == null) {
      debugPrint('Camera not initialized or controller is null');
      return null;
    }

    try {
      // Ensure camera is ready
      if (!state.controller!.value.isInitialized) {
        debugPrint('Camera controller not initialized');
        return null;
      }

      final image = await state.controller!.takePicture();
      return image;
    } catch (e) {
      debugPrint('Error taking picture: $e');
      if (mounted) {
        state = state.copyWith(
          status: CameraStatus.error,
          errorMessage: 'Failed to take picture: ${e.toString()}',
        );
      }
      return null;
    }
  }

  Future<void> toggleFlash() async {
    if (!state.isInitialized || state.controller == null) return;

    try {
      final newFlashState = !state.isFlashOn;
      await state.controller!
          .setFlashMode(newFlashState ? FlashMode.torch : FlashMode.off);

      if (mounted) {
        state = state.copyWith(isFlashOn: newFlashState);
      }
    } catch (e) {
      debugPrint('Error toggling flash: $e');
      if (mounted) {
        state = state.copyWith(
          status: CameraStatus.error,
          errorMessage: 'Failed to toggle flash: ${e.toString()}',
        );
      }
    }
  }

  Future<void> setFocusPoint(Offset point) async {
    if (!state.isInitialized || state.controller == null) return;

    try {
      // Convert screen coordinates to camera coordinates
      final size = state.controller!.value.previewSize!;
      final double x = point.dx / size.width;
      final double y = point.dy / size.height;

      await state.controller!.setFocusPoint(Offset(x, y));
      await state.controller!.setExposurePoint(Offset(x, y));
    } catch (e) {
      debugPrint('Error setting focus point: $e');
    }
  }

  Future<void> setZoomLevel(double zoom) async {
    if (!state.isInitialized || state.controller == null) return;

    try {
      final minZoom = await state.controller!.getMinZoomLevel();
      final maxZoom = await state.controller!.getMaxZoomLevel();

      final clampedZoom = zoom.clamp(minZoom, maxZoom);
      await state.controller!.setZoomLevel(clampedZoom);
    } catch (e) {
      debugPrint('Error setting zoom level: $e');
    }
  }

  Future<void> setExposureOffset(double offset) async {
    if (!state.isInitialized || state.controller == null) return;

    try {
      final minOffset = await state.controller!.getMinExposureOffset();
      final maxOffset = await state.controller!.getMaxExposureOffset();

      final clampedOffset = offset.clamp(minOffset, maxOffset);
      await state.controller!.setExposureOffset(clampedOffset);
    } catch (e) {
      debugPrint('Error setting exposure offset: $e');
    }
  }

  Future<void> pausePreview() async {
    if (!state.isInitialized || state.controller == null) return;

    try {
      await state.controller!.pausePreview();
    } catch (e) {
      debugPrint('Error pausing preview: $e');
    }
  }

  Future<void> resumePreview() async {
    if (!state.isInitialized || state.controller == null) return;

    try {
      await state.controller!.resumePreview();
    } catch (e) {
      debugPrint('Error resuming preview: $e');
    }
  }

  Future<void> cleanupResources() async {
    if (state.controller != null) {
      try {
        await state.controller!.dispose();
      } catch (e) {
        debugPrint('Error disposing camera controller: $e');
      }

      if (mounted) {
        state = state.copyWith(
          controller: null,
          status: CameraStatus.uninitialized,
        );
      }
    }
  }

  // Helper method to check if the notifier is still valid
  bool get isValid => mounted;

  @override
  void dispose() {
    // Clean up resources when the provider is disposed
    if (state.controller != null) {
      state.controller!.dispose();
    }
    super.dispose();
  }
}

// Provider definition with better error handling
final cameraProvider =
    StateNotifierProvider<CameraNotifier, CameraState>((ref) {
  // This should be initialized with the cameras from main.dart
  return CameraNotifier([]);
});

// Helper providers for camera state
final cameraStatusProvider = Provider<CameraStatus>((ref) {
  return ref.watch(cameraProvider).status;
});

final isCameraInitializedProvider = Provider<bool>((ref) {
  return ref.watch(cameraProvider).isInitialized;
});

final cameraErrorProvider = Provider<String?>((ref) {
  return ref.watch(cameraProvider).errorMessage;
});
