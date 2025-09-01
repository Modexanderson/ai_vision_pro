// utils/camera_mode
import 'package:flutter/material.dart';

import '../models/detection_result.dart';

enum CameraMode {
  object('Object Detection'),
  text('Text Recognition'),
  barcode('Barcode Scanner'),
  landmark('Landmark Recognition'),
  plant('Plant Identification'),
  animal('Animal Recognition'),
  food('Food Analysis'),
  document('Document Processing');

  const CameraMode(this.displayName);
  final String displayName;

  IconData get icon {
    switch (this) {
      case CameraMode.object:
        return Icons.category;
      case CameraMode.text:
        return Icons.text_fields;
      case CameraMode.barcode:
        return Icons.qr_code_scanner;
      case CameraMode.landmark:
        return Icons.place;
      case CameraMode.plant:
        return Icons.local_florist;
      case CameraMode.animal:
        return Icons.pets;
      case CameraMode.food:
        return Icons.restaurant;
      case CameraMode.document:
        return Icons.description;
    }
  }

  Color get color {
    switch (this) {
      case CameraMode.object:
        return Colors.blue;
      case CameraMode.text:
        return Colors.green;
      case CameraMode.barcode:
        return Colors.purple;
      case CameraMode.landmark:
        return Colors.red;
      case CameraMode.plant:
        return Colors.teal;
      case CameraMode.animal:
        return Colors.orange;
      case CameraMode.food:
        return Colors.amber;
      case CameraMode.document:
        return Colors.indigo;
    }
  }

  bool get requiresPremium {
    switch (this) {
      case CameraMode.object:
      case CameraMode.text:
      case CameraMode.barcode:
        return false;
      case CameraMode.landmark:
      case CameraMode.plant:
      case CameraMode.animal:
      case CameraMode.food:
      case CameraMode.document:
        return true;
    }
  }
}

// Error handling extension for better error messages
extension DetectionErrorExtension on DetectionResult {
  String get friendlyErrorMessage {
    if (error == null) return '';

    if (error!.contains('network')) {
      return 'Network connection failed. Please check your internet connection.';
    } else if (error!.contains('timeout')) {
      return 'The analysis took too long. Please try again.';
    } else if (error!.contains('permission')) {
      return 'Camera permission is required for object detection.';
    } else if (error!.contains('file')) {
      return 'Unable to process the image file. Please try a different image.';
    } else if (error!.contains('api')) {
      return 'Service temporarily unavailable. Please try again later.';
    } else if (error!.contains('premium')) {
      return 'This feature requires a premium subscription.';
    }

    return 'An unexpected error occurred. Please try again.';
  }

  String get errorCategory {
    if (error == null) return 'none';

    if (error!.contains('network') || error!.contains('timeout')) {
      return 'connectivity';
    } else if (error!.contains('permission')) {
      return 'permission';
    } else if (error!.contains('file') || error!.contains('image')) {
      return 'file';
    } else if (error!.contains('api') || error!.contains('service')) {
      return 'service';
    } else if (error!.contains('premium') || error!.contains('subscription')) {
      return 'premium';
    }

    return 'unknown';
  }
}

// Result quality assessment
extension ResultQualityExtension on DetectionResult {
  String get qualityAssessment {
    if (objects.isEmpty) return 'No objects detected';

    final avgConfidence = averageConfidence;
    if (avgConfidence >= 0.9) return 'Excellent';
    if (avgConfidence >= 0.8) return 'Very Good';
    if (avgConfidence >= 0.7) return 'Good';
    if (avgConfidence >= 0.6) return 'Fair';
    return 'Poor';
  }

  Color get qualityColor {
    final avgConfidence = averageConfidence;
    if (avgConfidence >= 0.8) return Colors.green;
    if (avgConfidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  List<String> get suggestions {
    final suggestions = <String>[];

    if (objects.isEmpty) {
      suggestions.addAll([
        'Try better lighting conditions',
        'Move closer to the object',
        'Ensure the object is clearly visible',
        'Clean the camera lens',
      ]);
    } else if (averageConfidence < 0.7) {
      suggestions.addAll([
        'Improve lighting for better accuracy',
        'Hold the camera steady',
        'Try a different angle',
        'Move closer to the object',
      ]);
    } else {
      suggestions.addAll([
        'Great detection! Try exploring similar objects',
        'Share your results with friends',
        'Save to your collection',
      ]);
    }

    return suggestions;
  }
}

// Detection statistics helper
class DetectionStatistics {
  final List<DetectionResult> results;

  DetectionStatistics(this.results);

  int get totalDetections =>
      results.fold(0, (sum, result) => sum + result.objects.length);

  double get averageConfidence {
    if (results.isEmpty) return 0.0;
    final allObjects = results.expand((result) => result.objects).toList();
    if (allObjects.isEmpty) return 0.0;
    return allObjects.fold<double>(0, (sum, obj) => sum + obj.confidence) /
        allObjects.length;
  }

  Map<String, int> get categoryBreakdown {
    final categories = <String, int>{};
    for (final result in results) {
      for (final object in result.objects) {
        final category = _categorizeObject(object.label);
        categories[category] = (categories[category] ?? 0) + 1;
      }
    }
    return categories;
  }

  List<String> get topCategories {
    final breakdown = categoryBreakdown;
    final sorted = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).map((e) => e.key).toList();
  }

  String _categorizeObject(String label) {
    final lowercaseLabel = label.toLowerCase();
    if (lowercaseLabel.contains('person') ||
        lowercaseLabel.contains('people')) {
      return 'People';
    } else if (lowercaseLabel.contains('car') ||
        lowercaseLabel.contains('vehicle')) {
      return 'Vehicles';
    } else if (lowercaseLabel.contains('food') ||
        lowercaseLabel.contains('eat')) {
      return 'Food';
    } else if (lowercaseLabel.contains('animal') ||
        lowercaseLabel.contains('pet')) {
      return 'Animals';
    } else if (lowercaseLabel.contains('plant') ||
        lowercaseLabel.contains('flower')) {
      return 'Plants';
    } else if (lowercaseLabel.contains('building') ||
        lowercaseLabel.contains('house')) {
      return 'Architecture';
    }
    return 'Objects';
  }
}
