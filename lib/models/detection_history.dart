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

  // Cloud / sync fields
  final String? imageUrl;
  final String? thumbnailUrl;
  final String uploadStatus;
  final bool syncedToCloud;
  final int retryCount;
  final DateTime? lastRetryAt;
  final String? failureReason;

  const DetectionHistory({
    required this.id,
    required this.imagePath,
    required this.detectedObjects,
    required this.averageConfidence,
    required this.timestamp,
    this.mode,

    // optional cloud fields
    this.imageUrl,
    this.thumbnailUrl,
    this.uploadStatus = 'pending',
    this.syncedToCloud = false,
    this.retryCount = 0,
    this.lastRetryAt,
    this.failureReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'detectedObjects': detectedObjects,
      'averageConfidence': averageConfidence,
      'timestamp': Timestamp.fromDate(timestamp),
      'mode': mode?.name,

      // cloud fields
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'uploadStatus': uploadStatus,
      'syncedToCloud': syncedToCloud,
      'retryCount': retryCount,
      'lastRetryAt': lastRetryAt?.toIso8601String(),
      'failureReason': failureReason,
    };
  }

  factory DetectionHistory.fromMap(Map<String, dynamic> map) {
    return DetectionHistory(
      id: map['id'] ?? '',
      imagePath: map['imagePath'] ?? '',
      detectedObjects: List<String>.from(map['detectedObjects'] ?? []),
      averageConfidence: (map['averageConfidence'] ?? 0).toDouble(),
      timestamp: (map['timestamp'] is Timestamp)
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      mode: map['mode'] != null
          ? CameraMode.values.firstWhere(
              (m) => m.name == map['mode'],
              orElse: () => CameraMode.object,
            )
          : null,

      // cloud fields
      imageUrl: map['imageUrl'],
      thumbnailUrl: map['thumbnailUrl'],
      uploadStatus: map['uploadStatus'] ?? 'pending',
      syncedToCloud: map['syncedToCloud'] ?? false,
      retryCount: map['retryCount'] ?? 0,
      lastRetryAt: map['lastRetryAt'] != null
          ? DateTime.tryParse(map['lastRetryAt'])
          : null,
      failureReason: map['failureReason'],
    );
  }
}
