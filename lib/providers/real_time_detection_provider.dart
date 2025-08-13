// providers/real_time_detection_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/detected_object.dart';
import '../services/ml_service.dart';
import '../utils/camera_mode.dart';

class RealTimeDetectionNotifier extends StateNotifier<List<DetectedObject>> {
  RealTimeDetectionNotifier() : super([]);

  final MLService _mlService = MLService();

  Future<void> processFrame(File imageFile, CameraMode mode) async {
    try {
      List<DetectedObject> objects = [];

      switch (mode) {
        case CameraMode.object:
          objects = await _mlService.detectObjects(imageFile);
          break;
        case CameraMode.text:
          objects = await _mlService.extractText(imageFile);
          break;
        case CameraMode.barcode:
          objects = await _mlService.scanBarcodes(imageFile);
          break;
        default:
          // For other modes, use basic object detection as fallback
          objects = await _mlService.detectObjects(imageFile);
      }

      // Filter out low confidence detections for real-time use
      final filteredObjects = objects
          .where((obj) => obj.confidence > 0.5)
          .take(5) // Limit to top 5 detections for performance
          .toList();

      state = filteredObjects;
    } catch (e) {
      debugPrint('Real-time detection error: $e');
      state = [];
    }
  }

  void clearDetections() {
    state = [];
  }

  @override
  void dispose() {
    _mlService.dispose();
    super.dispose();
  }
}

final realTimeDetectionProvider =
    StateNotifierProvider<RealTimeDetectionNotifier, List<DetectedObject>>(
        (ref) {
  return RealTimeDetectionNotifier();
});
