import 'package:flutter/material.dart';

class FeatureHighlight {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  FeatureHighlight({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}
