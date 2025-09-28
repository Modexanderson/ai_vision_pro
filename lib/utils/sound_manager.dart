// utils/sound_manager.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// class SoundManager {
//   static bool _soundEnabled = true;

//   static bool get soundEnabled => _soundEnabled;

//   static void setSoundEnabled(bool enabled) {
//     _soundEnabled = enabled;
//   }

//   static Future<void> playShutter() async {
//     if (!_soundEnabled) return;

//     try {
//       // Play system camera shutter sound
//       await SystemSound.play(SystemSoundType.click);
//     } catch (e) {
//       debugPrint('Sound playback error: $e');
//     }
//   }

//   static Future<void> playSuccess() async {
//     if (!_soundEnabled) return;

//     try {
//       await SystemSound.play(SystemSoundType.click);
//     } catch (e) {
//       debugPrint('Sound playback error: $e');
//     }
//   }

//   static Future<void> playError() async {
//     if (!_soundEnabled) return;

//     try {
//       await SystemSound.play(SystemSoundType.alert);
//     } catch (e) {
//       debugPrint('Sound playback error: $e');
//     }
//   }

//   static Future<void> playClick() async {
//     if (!_soundEnabled) return;

//     try {
//       await SystemSound.play(SystemSoundType.click);
//     } catch (e) {
//       debugPrint('Sound playback error: $e');
//     }
//   }
// }

// utils/sound_manager.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _isInitialized = true;
      debugPrint('✅ Enhanced Sound Manager initialized');
    } catch (e) {
      debugPrint('❌ Sound Manager initialization failed: $e');
    }
  }

  bool get soundEnabled => _soundEnabled;

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', enabled);
  }

  // Camera sounds
  Future<void> playShutter() async {
    if (!_soundEnabled) return;

    try {
      // Use system sound for shutter (more natural)
      await SystemSound.play(SystemSoundType.click);

      // Optional: Play custom shutter sound
      // await _playCustomSound('shutter.mp3', volume: 0.7);
    } catch (e) {
      debugPrint('Error playing shutter sound: $e');
    }
  }

  Future<void> playFocusSound() async {
    if (!_soundEnabled) return;

    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      debugPrint('Error playing focus sound: $e');
    }
  }

  // UI interaction sounds
  Future<void> playSuccess() async {
    if (!_soundEnabled) return;

    try {
      // Custom success sound or system sound
      await _playCustomSound('success.mp3', volume: 0.6);
    } catch (e) {
      // Fallback to system sound
      await SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> playError() async {
    if (!_soundEnabled) return;

    try {
      await _playCustomSound('error.mp3', volume: 0.5);
    } catch (e) {
      // Fallback to system sound
      await SystemSound.play(SystemSoundType.alert);
    }
  }

  Future<void> playDetectionComplete() async {
    if (!_soundEnabled) return;

    try {
      await _playCustomSound('detection_complete.mp3', volume: 0.8);
    } catch (e) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> playButtonTap() async {
    if (!_soundEnabled) return;

    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      debugPrint('Error playing button tap sound: $e');
    }
  }

  Future<void> playModeSwitch() async {
    if (!_soundEnabled) return;

    try {
      await _playCustomSound('mode_switch.mp3', volume: 0.4);
    } catch (e) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  // Notification sounds
  Future<void> playNotificationSound() async {
    if (!_soundEnabled) return;

    try {
      await _playCustomSound('notification.mp3', volume: 0.6);
    } catch (e) {
      await SystemSound.play(SystemSoundType.alert);
    }
  }

  Future<void> playAchievementUnlocked() async {
    if (!_soundEnabled) return;

    try {
      await _playCustomSound('achievement.mp3', volume: 0.9);
    } catch (e) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  // Real-time detection sounds
  Future<void> playObjectDetected() async {
    if (!_soundEnabled) return;

    try {
      await _playCustomSound('object_detected.mp3', volume: 0.3);
    } catch (e) {
      // Soft click for real-time detection
      await SystemSound.play(SystemSoundType.click);
    }
  }

  // Custom sound player
  Future<void> _playCustomSound(String soundFile, {double volume = 1.0}) async {
    try {
      await _audioPlayer.play(AssetSource('sounds/$soundFile'));
      await _audioPlayer.setVolume(volume);
    } catch (e) {
      debugPrint('Error playing custom sound $soundFile: $e');
      rethrow;
    }
  }

  // Sound for different confidence levels
  Future<void> playConfidenceSound(double confidence) async {
    if (!_soundEnabled) return;

    try {
      if (confidence >= 0.9) {
        await _playCustomSound('high_confidence.mp3', volume: 0.6);
      } else if (confidence >= 0.7) {
        await _playCustomSound('medium_confidence.mp3', volume: 0.5);
      } else {
        await _playCustomSound('low_confidence.mp3', volume: 0.4);
      }
    } catch (e) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

// Usage in settings_screen.dart - update the _updateSetting method:
/*
void _updateSetting(VoidCallback updateFunction) {
  setState(updateFunction);
  _saveSettings();
  
  // Update sound manager
  if (updateFunction.toString().contains('_soundEnabled')) {
    ref.read(soundManagerProvider).setSoundEnabled(_soundEnabled);
  }
}
*/
