// services/image_quality_manager.dart

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageQualityManager {
  static final ImageQualityManager _instance = ImageQualityManager._internal();
  factory ImageQualityManager() => _instance;
  ImageQualityManager._internal();

  bool _highQualityEnabled = false;
  bool _isInitialized = false;

  // Quality presets
  static const Map<String, ResolutionPreset> _qualityPresets = {
    'low': ResolutionPreset.low,
    'medium': ResolutionPreset.medium,
    'high': ResolutionPreset.high,
    'veryHigh': ResolutionPreset.veryHigh,
    'ultraHigh': ResolutionPreset.ultraHigh,
    'max': ResolutionPreset.max,
  };

  // Image quality settings
  static const Map<String, int> _imageQualitySettings = {
    'low': 70,
    'medium': 85,
    'high': 95,
    'premium': 100,
  };

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _highQualityEnabled = prefs.getBool('high_quality') ?? false;
      _isInitialized = true;
      debugPrint('Image Quality Manager initialized');
    } catch (e) {
      debugPrint('Image Quality Manager initialization failed: $e');
    }
  }

  bool get highQualityEnabled => _highQualityEnabled;

  Future<void> setHighQualityEnabled(bool enabled, bool isPremium) async {
    if (enabled && !isPremium) {
      throw Exception('High quality images require premium subscription');
    }

    _highQualityEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('high_quality', enabled);
  }

  // Get resolution preset based on settings and premium status
  ResolutionPreset getResolutionPreset(bool isPremium) {
    if (!_highQualityEnabled || !isPremium) {
      return ResolutionPreset.high; // Standard quality
    }

    return ResolutionPreset.max; // Maximum quality for premium users
  }

  // Get image quality percentage for image capture
  int getImageQuality(bool isPremium) {
    if (!_highQualityEnabled || !isPremium) {
      return _imageQualitySettings['medium']!; // 85% quality
    }

    return _imageQualitySettings['premium']!; // 100% quality
  }

  // Get camera options optimized for quality
  CameraOptions getCameraOptions(bool isPremium) {
    return CameraOptions(
      resolutionPreset: getResolutionPreset(isPremium),
      imageQuality: getImageQuality(isPremium),
      enableAudio: false, // Disable audio for image capture
      imageFormatGroup: isPremium && _highQualityEnabled
          ? ImageFormatGroup.jpeg
          : ImageFormatGroup.jpeg,
    );
  }

  // Estimate storage usage
  Map<String, dynamic> getStorageEstimate(bool isPremium) {
    final quality = getImageQuality(isPremium);
    final resolution = getResolutionPreset(isPremium);

    double estimatedSizePerImage = 0; // in MB

    switch (resolution) {
      case ResolutionPreset.low:
        estimatedSizePerImage = 0.5;
        break;
      case ResolutionPreset.medium:
        estimatedSizePerImage = 1.2;
        break;
      case ResolutionPreset.high:
        estimatedSizePerImage = 2.5;
        break;
      case ResolutionPreset.veryHigh:
        estimatedSizePerImage = 4.0;
        break;
      case ResolutionPreset.ultraHigh:
        estimatedSizePerImage = 6.0;
        break;
      case ResolutionPreset.max:
        estimatedSizePerImage = 8.0;
        break;
    }

    // Adjust for quality setting
    final qualityMultiplier = quality / 100.0;
    estimatedSizePerImage *= qualityMultiplier;

    return {
      'sizePerImage': estimatedSizePerImage,
      'resolution': resolution.name,
      'quality': quality,
      'isPremiumMode': isPremium && _highQualityEnabled,
      'storageWarning': estimatedSizePerImage > 5.0,
    };
  }

  // Get quality description for UI
  String getQualityDescription(bool isPremium) {
    if (!_highQualityEnabled || !isPremium) {
      return 'Standard Quality (High efficiency)';
    }

    return 'Premium Quality (Maximum detail)';
  }

  // Get recommended settings based on use case
  Map<String, dynamic> getRecommendedSettings(String useCase, bool isPremium) {
    switch (useCase.toLowerCase()) {
      case 'social_sharing':
        return {
          'preset': ResolutionPreset.high,
          'quality': 85,
          'description': 'Optimized for social media sharing',
        };
      case 'document_scanning':
        return {
          'preset':
              isPremium ? ResolutionPreset.max : ResolutionPreset.veryHigh,
          'quality': isPremium ? 100 : 95,
          'description': 'High detail for text recognition',
        };
      case 'archival':
        return {
          'preset': isPremium ? ResolutionPreset.max : ResolutionPreset.high,
          'quality': isPremium ? 100 : 85,
          'description': 'Long-term storage quality',
        };
      case 'real_time':
        return {
          'preset': ResolutionPreset.medium,
          'quality': 70,
          'description': 'Fast processing for real-time detection',
        };
      default:
        return {
          'preset': getResolutionPreset(isPremium),
          'quality': getImageQuality(isPremium),
          'description': 'Default quality settings',
        };
    }
  }

  // Check if device can handle high quality
  Future<bool> canHandleHighQuality() async {
    // Basic device capability check
    // In a real app, you'd check RAM, storage, etc.
    try {
      // Placeholder for device capability check
      return true; // Assume most modern devices can handle it
    } catch (e) {
      return false;
    }
  }

  // Quality metrics for analytics
  Map<String, dynamic> getQualityMetrics() {
    return {
      'highQualityEnabled': _highQualityEnabled,
      'currentPreset': getResolutionPreset(true).name,
      'currentQuality': getImageQuality(true),
      'estimatedSize': getStorageEstimate(true)['sizePerImage'],
    };
  }
}

// Camera options helper class
class CameraOptions {
  final ResolutionPreset resolutionPreset;
  final int imageQuality;
  final bool enableAudio;
  final ImageFormatGroup imageFormatGroup;

  const CameraOptions({
    required this.resolutionPreset,
    required this.imageQuality,
    required this.enableAudio,
    required this.imageFormatGroup,
  });
}
