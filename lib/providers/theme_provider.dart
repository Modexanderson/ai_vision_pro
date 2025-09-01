import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Load saved theme preference
    _loadTheme();
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme') ?? 'System';
    state = savedTheme == 'Light'
        ? ThemeMode.light
        : savedTheme == 'Dark'
            ? ThemeMode.dark
            : ThemeMode.system;
  }

  void setThemeMode(String theme) {
    state = theme == 'Light'
        ? ThemeMode.light
        : theme == 'Dark'
            ? ThemeMode.dark
            : ThemeMode.system;
  }
}

final themeNotifierProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  () => ThemeNotifier(),
);
