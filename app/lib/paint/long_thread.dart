import 'package:flutter/material.dart';

import '../theme/tokens.dart';

class LongThread extends StatelessWidget {
  const LongThread({super.key, this.width = 180, this.height = 24});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(size: Size(width, height), painter: LongThreadPainter()),
  );
}

class LongThreadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.78)
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.78,
        size.width * 0.62,
        size.height * 0.2,
        size.width,
        size.height * 0.2,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = WashijColors.starYellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant LongThreadPainter oldDelegate) => false;
}
