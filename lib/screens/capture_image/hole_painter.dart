import 'package:flutter/material.dart';

class HolePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      // ignore: deprecated_member_use
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final holeWidth = size.width * 0.9;
    final holeHeight = holeWidth / (85.6 / 54.0);
    final dx = (size.width - holeWidth) / 2;
    final dy = (size.height - holeHeight) / 2;

    final outer = Rect.fromLTWH(0, 0, size.width, size.height);
    final hole = RRect.fromRectXY(Rect.fromLTWH(dx, dy, holeWidth, holeHeight), 8, 8);

    final path = Path()
      ..addRect(outer)
      ..addRRect(hole)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
