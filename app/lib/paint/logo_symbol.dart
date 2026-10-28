import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

class LogoSymbol extends StatelessWidget {
  const LogoSymbol({
    super.key,
    this.size = 36,
    this.color = WashijColors.ivory,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: LogoSymbolPainter(color: color),
    isComplex: true,
  );
}

class LogoSymbolPainter extends CustomPainter {
  const LogoSymbolPainter({this.color = WashijColors.ivory});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final gridScale = size.width / 120;
    final stroke = size.width <= 16
        ? 7.0
        : size.width <= 32
        ? 5.0
        : 3.2;
    final crossingY = 98 + (22 - 98) / 108 * (33 - 6);
    final gapY = (stroke / 2 + stroke) / math.cos(math.atan(76 / 108));
    final frame = Path()
      ..moveTo(33, crossingY - gapY)
      ..lineTo(33, 15)
      ..lineTo(87, 15)
      ..lineTo(87, 105)
      ..lineTo(33, 105)
      ..lineTo(33, crossingY + gapY);
    final basePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeJoin = StrokeJoin.miter;
    canvas.save();
    canvas.scale(gridScale);
    canvas.drawPath(frame, basePaint);

    final rightGap = stroke * 2;
    final leftEnd = 87 - rightGap;
    final rightStart = 87 + rightGap;
    double yAt(double x) => 98 + (22 - 98) / 108 * (x - 6);
    final thread = Path()
      ..moveTo(6, 98)
      ..lineTo(33, crossingY)
      ..lineTo(leftEnd, yAt(leftEnd))
      ..moveTo(rightStart, yAt(rightStart))
      ..lineTo(114, 22);
    canvas.drawPath(
      thread,
      Paint()
        ..color = WashijColors.starYellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LogoSymbolPainter oldDelegate) =>
      color != oldDelegate.color;
}
