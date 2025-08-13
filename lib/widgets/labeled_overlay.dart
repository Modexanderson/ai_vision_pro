// widgets/labeled_overlay.dart

import 'package:flutter/material.dart';
import 'package:ai_vision_pro/models/detected_object.dart';
import 'package:ai_vision_pro/models/detection_result.dart';

class LabeledOverlay extends StatelessWidget {
  final DetectionResult result;
  final Function(DetectedObject) onTapLabel;

  const LabeledOverlay({
    super.key,
    required this.result,
    required this.onTapLabel,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BoundingBoxPainter(result.objects),
      child: Stack(
        children: result.objects.map((object) {
          // Position the label at the top of the bounding box
          return Positioned(
            left: object.boundingBox.left,
            top: object.boundingBox.top - 30, // Position above the box
            child: GestureDetector(
              onTap: () => onTapLabel(object),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getColorForConfidence(object.confidence),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${object.label} ${(object.confidence * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getColorForConfidence(double confidence) {
    if (confidence >= 0.7) {
      return Colors.green;
    } else if (confidence >= 0.4) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<DetectedObject> objects;

  BoundingBoxPainter(this.objects);

  @override
  void paint(Canvas canvas, Size size) {
    for (final object in objects) {
      final paint = Paint()
        ..color = _getColorForConfidence(object.confidence)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRect(object.boundingBox, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  Color _getColorForConfidence(double confidence) {
    if (confidence >= 0.7) {
      return Colors.green;
    } else if (confidence >= 0.4) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
