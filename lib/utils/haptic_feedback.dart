// // utils/haptic_feedback.dart

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class HapticFeedbackUtil {
//   static Future<void> lightImpact() async {
//     try {
//       await HapticFeedback.lightImpact();
//     } catch (e) {
//       debugPrint('Haptic feedback error: $e');
//     }
//   }

//   static Future<void> mediumImpact() async {
//     try {
//       await HapticFeedback.mediumImpact();
//     } catch (e) {
//       debugPrint('Haptic feedback error: $e');
//     }
//   }

//   static Future<void> heavyImpact() async {
//     try {
//       await HapticFeedback.heavyImpact();
//     } catch (e) {
//       debugPrint('Haptic feedback error: $e');
//     }
//   }

//   static Future<void> selectionClick() async {
//     try {
//       await HapticFeedback.selectionClick();
//     } catch (e) {
//       debugPrint('Haptic feedback error: $e');
//     }
//   }

//   static Future<void> vibrate() async {
//     try {
//       await HapticFeedback.vibrate();
//     } catch (e) {
//       debugPrint('Haptic feedback error: $e');
//     }
//   }
// }

// utils/haptic_feedback.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HapticFeedbackUtil {
  static final HapticFeedbackUtil _instance = HapticFeedbackUtil._internal();
  factory HapticFeedbackUtil() => _instance;
  HapticFeedbackUtil._internal();

  bool _hapticEnabled = true;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _hapticEnabled = prefs.getBool('haptic_enabled') ?? true;
      _isInitialized = true;
      debugPrint('Enhanced Haptic Feedback initialized');
    } catch (e) {
      debugPrint('Haptic feedback initialization failed: $e');
    }
  }

  bool get hapticEnabled => _hapticEnabled;

  Future<void> setHapticEnabled(bool enabled) async {
    _hapticEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptic_enabled', enabled);
  }

  // Camera-related haptics
  Future<void> capturePhoto() async {
    if (!_hapticEnabled) return;

    try {
      // Strong impact for photo capture
      await HapticFeedback.heavyImpact();

      // Quick double tap effect
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Error with capture haptic: $e');
    }
  }

  Future<void> focusTap() async {
    if (!_hapticEnabled) return;

    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Error with focus haptic: $e');
    }
  }

  Future<void> modeSwitch() async {
    if (!_hapticEnabled) return;

    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Error with mode switch haptic: $e');
    }
  }

  Future<void> cameraSwitch() async {
    if (!_hapticEnabled) return;

    try {
      // Double tap pattern
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Error with camera switch haptic: $e');
    }
  }

  // Detection-related haptics
  Future<void> detectionStart() async {
    if (!_hapticEnabled) return;

    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Error with detection start haptic: $e');
    }
  }

  Future<void> detectionComplete({double confidence = 0.5}) async {
    if (!_hapticEnabled) return;

    try {
      if (confidence >= 0.9) {
        // High confidence: Strong success pattern
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.lightImpact();
      } else if (confidence >= 0.7) {
        // Medium confidence: Medium success pattern
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.lightImpact();
      } else {
        // Low confidence: Simple completion
        await HapticFeedback.lightImpact();
      }
    } catch (e) {
      debugPrint('Error with detection complete haptic: $e');
    }
  }

  Future<void> detectionError() async {
    if (!_hapticEnabled) return;

    try {
      // Error pattern: Three quick light impacts
      for (int i = 0; i < 3; i++) {
        await HapticFeedback.lightImpact();
        if (i < 2) await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      debugPrint('Error with detection error haptic: $e');
    }
  }

  Future<void> objectFound() async {
    if (!_hapticEnabled) return;

    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Error with object found haptic: $e');
    }
  }

  // UI interaction haptics
  Future<void> buttonTap() async {
    if (!_hapticEnabled) return;

    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Error with button tap haptic: $e');
    }
  }

  Future<void> toggleSwitch() async {
    if (!_hapticEnabled) return;

    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Error with toggle switch haptic: $e');
    }
  }

  Future<void> listSelection() async {
    if (!_hapticEnabled) return;

    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Error with list selection haptic: $e');
    }
  }

  Future<void> pageTransition() async {
    if (!_hapticEnabled) return;

    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Error with page transition haptic: $e');
    }
  }

  // Success/Error feedback
  Future<void> success() async {
    if (!_hapticEnabled) return;

    try {
      // Success pattern: Medium followed by two light impacts
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 60));
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 60));
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Error with success haptic: $e');
    }
  }

  Future<void> warning() async {
    if (!_hapticEnabled) return;

    try {
      // Warning pattern: Two medium impacts
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 120));
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Error with warning haptic: $e');
    }
  }

  Future<void> error() async {
    if (!_hapticEnabled) return;

    try {
      // Error pattern: Heavy followed by light
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Error with error haptic: $e');
    }
  }

  // Achievement and gamification
  Future<void> achievementUnlocked() async {
    if (!_hapticEnabled) return;

    try {
      // Achievement pattern: Celebration-style vibration
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 40));
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 40));
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Error with achievement haptic: $e');
    }
  }

  Future<void> levelUp() async {
    if (!_hapticEnabled) return;

    try {
      // Level up pattern: Ascending intensity
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Error with level up haptic: $e');
    }
  }

  // Premium features
  Future<void> premiumFeatureAccess() async {
    if (!_hapticEnabled) return;

    try {
      // Premium access pattern: Smooth double tap
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Error with premium access haptic: $e');
    }
  }

  Future<void> premiumFeatureBlocked() async {
    if (!_hapticEnabled) return;

    try {
      // Blocked pattern: Quick light taps
      for (int i = 0; i < 2; i++) {
        await HapticFeedback.lightImpact();
        if (i < 1) await Future.delayed(const Duration(milliseconds: 60));
      }
    } catch (e) {
      debugPrint('Error with premium blocked haptic: $e');
    }
  }

  // Batch operations
  Future<void> batchModeStart() async {
    if (!_hapticEnabled) return;

    try {
      // Batch start: Quick ascending pattern
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Error with batch mode start haptic: $e');
    }
  }

  Future<void> batchItemCapture(int itemNumber, int totalItems) async {
    if (!_hapticEnabled) return;

    try {
      if (itemNumber == totalItems) {
        // Last item: Complete batch pattern
        await success();
      } else {
        // Regular item: Simple tap
        await HapticFeedback.lightImpact();
      }
    } catch (e) {
      debugPrint('Error with batch item capture haptic: $e');
    }
  }

  // Real-time detection (gentle feedback)
  Future<void> realTimeDetection() async {
    if (!_hapticEnabled) return;

    try {
      // Very gentle feedback for real-time
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Error with real-time detection haptic: $e');
    }
  }
}
