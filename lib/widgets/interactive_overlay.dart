// widgets/interactive_overlay.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/detection_result.dart';
import '../models/detected_object.dart';

class InteractiveOverlay extends StatefulWidget {
  final DetectionResult result;
  final Function(DetectedObject) onObjectTap;
  final double scale;

  const InteractiveOverlay({
    super.key,
    required this.result,
    required this.onObjectTap,
    this.scale = 1.0,
  });

  @override
  State<InteractiveOverlay> createState() => _InteractiveOverlayState();
}

class _InteractiveOverlayState extends State<InteractiveOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  String? _hoveredObjectId;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: widget.result.objects.asMap().entries.map((entry) {
        final index = entry.key;
        final object = entry.value;
        return _buildObjectOverlay(object, index);
      }).toList(),
    );
  }

  Widget _buildObjectOverlay(DetectedObject object, int index) {
    final isHovered = _hoveredObjectId == object.id;
    final boundingBox = _adjustBoundingBoxForScale(object.boundingBox);

    return Positioned(
      left: boundingBox.left,
      top: boundingBox.top,
      child: GestureDetector(
        onTap: () => widget.onObjectTap(object),
        onTapDown: (_) => setState(() => _hoveredObjectId = object.id),
        onTapUp: (_) => setState(() => _hoveredObjectId = null),
        onTapCancel: () => setState(() => _hoveredObjectId = null),
        child: Container(
          width: boundingBox.width,
          height: boundingBox.height,
          decoration: BoxDecoration(
            border: Border.all(
              color: _getConfidenceColor(object.confidence),
              width: isHovered ? 3 : 2,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isHovered
                ? _getConfidenceColor(object.confidence).withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Stack(
            children: [
              // Pulsing corner indicators
              if (isHovered) ..._buildCornerIndicators(object),

              // Object label
              Positioned(
                top: -25,
                left: 0,
                child: _buildObjectLabel(object, isHovered),
              ),

              // Confidence indicator
              Positioned(
                bottom: -20,
                right: 0,
                child: _buildConfidenceIndicator(object),
              ),
            ],
          ),
        ),
      ).animate(delay: (index * 150).ms).fadeIn().scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
          ),
    );
  }

  Widget _buildObjectLabel(DetectedObject object, bool isHighlighted) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlighted
            ? _getConfidenceColor(object.confidence)
            : _getConfidenceColor(object.confidence).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color:
                      _getConfidenceColor(object.confidence).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getObjectIcon(object.label),
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            object.label,
            style: TextStyle(
              color: Colors.white,
              fontSize: isHighlighted ? 13 : 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceIndicator(DetectedObject object) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${(object.confidence * 100).toInt()}%',
        style: TextStyle(
          color: _getConfidenceColor(object.confidence),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Widget> _buildCornerIndicators(DetectedObject object) {
    return [
      // Top-left corner
      Positioned(
        top: 0,
        left: 0,
        child: _buildCornerIndicator(),
      ),
      // Top-right corner
      Positioned(
        top: 0,
        right: 0,
        child: _buildCornerIndicator(),
      ),
      // Bottom-left corner
      Positioned(
        bottom: 0,
        left: 0,
        child: _buildCornerIndicator(),
      ),
      // Bottom-right corner
      Positioned(
        bottom: 0,
        right: 0,
        child: _buildCornerIndicator(),
      ),
    ];
  }

  Widget _buildCornerIndicator() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                blurRadius: 4 + (_pulseController.value * 2),
                spreadRadius: _pulseController.value * 2,
              ),
            ],
          ),
        );
      },
    );
  }

  Rect _adjustBoundingBoxForScale(Rect originalBox) {
    // Adjust bounding box coordinates based on image scale
    // This ensures the overlay remains accurate when zooming
    return Rect.fromLTWH(
      originalBox.left / widget.scale,
      originalBox.top / widget.scale,
      originalBox.width / widget.scale,
      originalBox.height / widget.scale,
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  IconData _getObjectIcon(String label) {
    final lowercaseLabel = label.toLowerCase();
    if (lowercaseLabel.contains('person') ||
        lowercaseLabel.contains('people')) {
      return Icons.person;
    } else if (lowercaseLabel.contains('car') ||
        lowercaseLabel.contains('vehicle')) {
      return Icons.directions_car;
    } else if (lowercaseLabel.contains('food') ||
        lowercaseLabel.contains('eat')) {
      return Icons.restaurant;
    } else if (lowercaseLabel.contains('animal') ||
        lowercaseLabel.contains('dog') ||
        lowercaseLabel.contains('cat')) {
      return Icons.pets;
    } else if (lowercaseLabel.contains('plant') ||
        lowercaseLabel.contains('flower')) {
      return Icons.local_florist;
    } else if (lowercaseLabel.contains('book') ||
        lowercaseLabel.contains('text')) {
      return Icons.book;
    } else if (lowercaseLabel.contains('phone') ||
        lowercaseLabel.contains('mobile')) {
      return Icons.phone_android;
    } else if (lowercaseLabel.contains('computer') ||
        lowercaseLabel.contains('laptop')) {
      return Icons.computer;
    } else if (lowercaseLabel.contains('building') ||
        lowercaseLabel.contains('house')) {
      return Icons.home;
    } else if (lowercaseLabel.contains('clock') ||
        lowercaseLabel.contains('watch')) {
      return Icons.access_time;
    } else if (lowercaseLabel.contains('bottle') ||
        lowercaseLabel.contains('cup')) {
      return Icons.local_drink;
    } else if (lowercaseLabel.contains('bag') ||
        lowercaseLabel.contains('backpack')) {
      return Icons.shopping_bag;
    }
    return Icons.category;
  }
}

// Additional utility classes and widgets

class HapticFeedbackUtil {
  static void lightImpact() {
    try {
      // This would implement haptic feedback
      // For now, it's a placeholder
    } catch (e) {
      // Ignore if haptic feedback is not available
    }
  }

  static void mediumImpact() {
    try {
      // This would implement haptic feedback
      // For now, it's a placeholder
    } catch (e) {
      // Ignore if haptic feedback is not available
    }
  }

  static void heavyImpact() {
    try {
      // This would implement haptic feedback
      // For now, it's a placeholder
    } catch (e) {
      // Ignore if haptic feedback is not available
    }
  }
}
