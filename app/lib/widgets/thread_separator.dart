import 'package:flutter/material.dart';

import '../theme/tokens.dart';

class ThreadSeparator extends StatelessWidget {
  const ThreadSeparator({super.key, this.height = 24});

  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: const CustomPaint(painter: _ThreadSeparatorPainter()),
  );
}

class _ThreadSeparatorPainter extends CustomPainter {
  const _ThreadSeparatorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final center = size.width / 2;
    final gap = size.width < 500 ? 14.0 : 24.0;
    final rule = Paint()
      ..color = WashijColors.hairline
      ..strokeWidth = 1;
    final thread = Paint()
      ..color = WashijColors.starYellow
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero.translate(0, y), Offset(center - gap, y), rule);
    canvas.drawLine(Offset(center + gap, y), Offset(size.width, y), rule);
    canvas.drawLine(
      Offset(center - gap * 0.65, y + 6),
      Offset(center + gap * 0.65, y - 6),
      thread,
    );
  }

  @override
  bool shouldRepaint(covariant _ThreadSeparatorPainter oldDelegate) => false;
}
