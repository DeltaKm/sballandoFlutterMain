import 'package:flutter/material.dart';

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashHeight;
  final double dashSpace;

  DashedLinePainter({
    required this.color,
    this.strokeWidth = 6,
    this.dashHeight = 10,
    this.dashSpace = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    double startY = 0;
    while (startY < size.height) {
      // Disegna una "tratta" dalla posizione startY a startY + dashHeight
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class VerticalDashedLine extends StatelessWidget {
  final double height;
  final Color color;

  const VerticalDashedLine({
    super.key,
    required this.height,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
  size: Size(6, height), // larghezza coerente con strokeWidth
  painter: DashedLinePainter(
    color: color,
    strokeWidth: 6,
    dashHeight: 10,
    dashSpace: 6,
  ),
);
  }
}
