// widgets/grid_painter.dart

import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final Color lineColor;
  final double strokeWidth;

  GridPainter({
    this.lineColor = Colors.white,
    this.strokeWidth = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor.withOpacity(0.3)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw vertical lines (rule of thirds)
    final double verticalSpacing = size.width / 3;
    for (int i = 1; i < 3; i++) {
      final double x = verticalSpacing * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines (rule of thirds)
    final double horizontalSpacing = size.height / 3;
    for (int i = 1; i < 3; i++) {
      final double y = horizontalSpacing * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
