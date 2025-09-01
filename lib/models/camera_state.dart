// models/camera_state.dart

import 'package:camera/camera.dart';

enum CameraStatus {
  uninitialized,
  initializing,
  initialized,
  streaming,
  error,
}

class CameraState {
  final CameraController? controller;
  final CameraStatus status;
  final int selectedCameraIndex;
  final List<CameraDescription> cameras;
  final String? errorMessage;
  final bool isFlashOn;
  final bool isHDREnabled;

  CameraState({
    this.controller,
    this.status = CameraStatus.uninitialized,
    this.selectedCameraIndex = 0,
    this.cameras = const [],
    this.errorMessage,
    this.isFlashOn = false,
    this.isHDREnabled = false,
  });

  bool get isInitialized =>
      controller != null && controller!.value.isInitialized;

  bool get isReady => isInitialized && status == CameraStatus.streaming;

  CameraState copyWith({
    CameraController? controller,
    CameraStatus? status,
    int? selectedCameraIndex,
    List<CameraDescription>? cameras,
    String? errorMessage,
    bool? isFlashOn,
    bool? isHDREnabled,
  }) {
    return CameraState(
      controller: controller ?? this.controller,
      status: status ?? this.status,
      selectedCameraIndex: selectedCameraIndex ?? this.selectedCameraIndex,
      cameras: cameras ?? this.cameras,
      errorMessage: errorMessage ?? this.errorMessage,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      isHDREnabled: isHDREnabled ?? this.isHDREnabled,
    );
  }

  @override
  String toString() {
    return 'CameraState(status: $status, isInitialized: $isInitialized, selectedCamera: $selectedCameraIndex)';
  }
}
