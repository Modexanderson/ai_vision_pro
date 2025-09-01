// models/detection_history.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/camera_mode.dart';

class DetectionHistory {
  final String id;
  final String imagePath;
  final List<String> detectedObjects;
  final double averageConfidence;
  final DateTime timestamp;
  final CameraMode? mode;

  DetectionHistory({
    required this.id,
    required this.imagePath,
    required this.detectedObjects,
    required this.averageConfidence,
    required this.timestamp,
    this.mode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'detectedObjects': detectedObjects,
      'averageConfidence': averageConfidence,
      'timestamp': Timestamp.fromDate(timestamp),
      'mode': mode?.name,
    };
  }

  factory DetectionHistory.fromMap(Map<String, dynamic> map) {
    return DetectionHistory(
      id: map['id'] ?? '',
      imagePath: map['imagePath'] ?? '',
      detectedObjects: List<String>.from(map['detectedObjects'] ?? []),
      averageConfidence: map['averageConfidence']?.toDouble() ?? 0.0,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      mode: map['mode'] != null
          ? CameraMode.values.firstWhere(
              (m) => m.name == map['mode'],
              orElse: () => CameraMode.object,
            )
          : null,
    );
  }
}
