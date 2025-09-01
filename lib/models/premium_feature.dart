// models/premium_feature.dart

import 'package:flutter/material.dart';

class PremiumFeature {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isAvailable;

  PremiumFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.isAvailable = true,
  });

  PremiumFeature copyWith({
    IconData? icon,
    String? title,
    String? description,
    Color? color,
    bool? isAvailable,
  }) {
    return PremiumFeature(
      icon: icon ?? this.icon,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isAvailable': isAvailable,
    };
  }

  factory PremiumFeature.fromJson(Map<String, dynamic> json) {
    return PremiumFeature(
      icon: Icons.star, // Default icon when loading from JSON
      title: json['title'],
      description: json['description'],
      color: Colors.blue, // Default color when loading from JSON
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  @override
  String toString() {
    return 'PremiumFeature(title: $title, description: $description, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PremiumFeature &&
        other.title == title &&
        other.description == description &&
        other.isAvailable == isAvailable;
  }

  @override
  int get hashCode {
    return Object.hash(title, description, isAvailable);
  }
}
