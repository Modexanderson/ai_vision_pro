// models/achievement.dart

import 'package:flutter/material.dart';

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final Color color;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.color,
  });
}
