// utils/sound_manager.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SoundManager {
  static bool _soundEnabled = true;

  static bool get soundEnabled => _soundEnabled;

  static void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  static Future<void> playShutter() async {
    if (!_soundEnabled) return;

    try {
      // Play system camera shutter sound
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      debugPrint('Sound playback error: $e');
    }
  }

  static Future<void> playSuccess() async {
    if (!_soundEnabled) return;

    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      debugPrint('Sound playback error: $e');
    }
  }

  static Future<void> playError() async {
    if (!_soundEnabled) return;

    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      debugPrint('Sound playback error: $e');
    }
  }

  static Future<void> playClick() async {
    if (!_soundEnabled) return;

    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      debugPrint('Sound playback error: $e');
    }
  }
}
