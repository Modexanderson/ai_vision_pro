import 'package:ai_vision_pro/utils/camera_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DetectionResultOverlay extends StatelessWidget {
  final List<dynamic> detections;
  final CameraMode mode;
  final bool isRealTime;

  const DetectionResultOverlay({
    super.key,
    required this.detections,
    required this.mode,
    this.isRealTime = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: detections.map((detection) {
        return Positioned(
          left: detection.boundingBox.left,
          top: detection.boundingBox.top,
          child: Container(
            width: detection.boundingBox.width,
            height: detection.boundingBox.height,
            decoration: BoxDecoration(
              border: Border.all(
                color: _getModeColor(mode),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getModeColor(mode),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  '${detection.label} ${(detection.confidence * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.8, 0.8))
              .then()
              .shimmer(duration: 1000.ms),
        );
      }).toList(),
    );
  }

  Color _getModeColor(CameraMode mode) {
    switch (mode) {
      case CameraMode.object:
        return Colors.blue;
      case CameraMode.text:
        return Colors.green;
      case CameraMode.barcode:
        return Colors.purple;
      case CameraMode.landmark:
        return Colors.orange;
      case CameraMode.plant:
        return Colors.teal;
      case CameraMode.animal:
        return Colors.brown;
      case CameraMode.food:
        return Colors.red;
      case CameraMode.document:
        return Colors.indigo;
    }
  }
}
