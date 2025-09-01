// models/detection_result.dart

import 'dart:io';
import '../utils/camera_mode.dart';
import 'detected_object.dart';

class DetectionResult {
  final String id;
  final File imageFile;
  final List<DetectedObject> objects;
  final DateTime timestamp;
  final bool isProcessing;
  final String? error;
  final CameraMode? mode;
  final String? deepAnalysis;

  DetectionResult({
    required this.id,
    required this.imageFile,
    required this.objects,
    required this.timestamp,
    this.isProcessing = false,
    this.error,
    this.mode,
    this.deepAnalysis,
  });

  // Add the hasError getter that was missing
  bool get hasError => error != null;

  // Add helper getters
  bool get isSuccessful => !hasError && !isProcessing;
  bool get hasObjects => objects.isNotEmpty;
  double get averageConfidence {
    if (objects.isEmpty) return 0.0;
    return objects.fold<double>(0, (sum, obj) => sum + obj.confidence) /
        objects.length;
  }

  DetectionResult copyWith({
    String? id,
    File? imageFile,
    List<DetectedObject>? objects,
    DateTime? timestamp,
    bool? isProcessing,
    String? error,
    CameraMode? mode,
    String? deepAnalysis,
  }) {
    return DetectionResult(
      id: id ?? this.id,
      imageFile: imageFile ?? this.imageFile,
      objects: objects ?? this.objects,
      timestamp: timestamp ?? this.timestamp,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error ?? this.error,
      mode: mode ?? this.mode,
      deepAnalysis: deepAnalysis ?? this.deepAnalysis,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imageFile.path,
        'objects': objects.map((obj) => obj.toJson()).toList(),
        'timestamp': timestamp.toIso8601String(),
        'isProcessing': isProcessing,
        'error': error,
        'mode': mode?.name,
        'deepAnalysis': deepAnalysis,
      };

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      id: json['id'],
      imageFile: File(json['imagePath']),
      objects: (json['objects'] as List)
          .map((obj) => DetectedObject.fromJson(obj))
          .toList(),
      timestamp: DateTime.parse(json['timestamp']),
      isProcessing: json['isProcessing'] ?? false,
      error: json['error'],
      mode: json['mode'] != null
          ? CameraMode.values.firstWhere((e) => e.name == json['mode'])
          : null,
      deepAnalysis: json['deepAnalysis'],
    );
  }
}
