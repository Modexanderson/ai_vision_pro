// utils/haptic_feedback.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HapticFeedbackUtil {
  static Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Haptic feedback error: $e');
    }
  }

  static Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Haptic feedback error: $e');
    }
  }

  static Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Haptic feedback error: $e');
    }
  }

  static Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Haptic feedback error: $e');
    }
  }

  static Future<void> vibrate() async {
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      debugPrint('Haptic feedback error: $e');
    }
  }
}
