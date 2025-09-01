// models/detection_state.dart
import 'detection_result.dart';

class DetectionState {
  final DetectionResult? currentResult;
  final bool isLoading;
  final String? error;

  DetectionState({
    this.currentResult,
    this.isLoading = false,
    this.error,
  });

  DetectionState.initial() : this();

  DetectionState copyWith({
    DetectionResult? currentResult,
    bool? isLoading,
    String? error,
  }) {
    return DetectionState(
      currentResult: currentResult ?? this.currentResult,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
