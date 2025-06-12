import 'package:flutter/material.dart';
import 'hole_painter.dart';

class CameraOverlay extends StatelessWidget {
  const CameraOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardWidth = screenWidth * 0.9;
    final cardHeight = cardWidth / (85.6 / 54.0);
    final left = (screenWidth - cardWidth) / 2;
    final top = (screenHeight - cardHeight) / 2;

    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: HolePainter())),
        Positioned(
          left: left,
          top: top,
          width: cardWidth,
          height: cardHeight,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.greenAccent, width: 3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
