import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../paint/logo_symbol.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

class WashijNightSplash extends StatefulWidget {
  const WashijNightSplash({super.key});

  @override
  State<WashijNightSplash> createState() => _WashijNightSplashState();
}

class _WashijNightSplashState extends State<WashijNightSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward();

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final size = MediaQuery.sizeOf(context);
    final markSize = math.min(size.shortestSide * .34, 200.0);
    final entrance = reducedMotion
        ? const AlwaysStoppedAnimation(1.0)
        : CurvedAnimation(parent: _entrance, curve: Curves.easeOut);

    return Material(
      color: WashijColors.midnight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const CustomPaint(painter: _NightSkyPainter()),
          Center(
            child: FadeTransition(
              opacity: entrance,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LogoSymbol(size: markSize),
                  const SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'و'),
                        TextSpan(
                          text: 'َ',
                          style: TextStyle(color: WashijColors.starYellow),
                        ),
                        const TextSpan(text: 'شيج'),
                      ],
                    ),
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: WashijFonts.wordmark,
                      fontWeight: FontWeight.w700,
                      fontSize: math.min(size.shortestSide * .08, 56.0),
                      height: 1,
                      color: WashijColors.ivory,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'WASHIJ',
                    textDirection: TextDirection.ltr,
                    style: WashijTypography.englishDisplay.copyWith(
                      color: WashijColors.mist,
                      fontSize: 14,
                      letterSpacing: 4.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NightSkyPainter extends CustomPainter {
  const _NightSkyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          WashijColors.midnight,
          WashijColors.deepBlue,
          WashijColors.nightRaised,
        ],
        stops: [0, .7, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    final random = math.Random(41);
    for (var i = 0; i < 110; i++) {
      final isYellow = i % 9 == 0;
      final radius = isYellow
          ? 1.5 + random.nextDouble() * 1.5
          : .5 + random.nextDouble();
      final center = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height * .72,
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = isYellow
              ? WashijColors.starYellow.withValues(alpha: .85)
              : WashijColors.ivory.withValues(alpha: .65),
      );
    }

    canvas.save();
    canvas.translate(0, size.height * .7);
    canvas.scale(size.width / 1200, size.height * .3 / 300);
    final firstWave = Path()
      ..moveTo(0, 200)
      ..cubicTo(200, 150, 400, 250, 600, 190)
      ..cubicTo(800, 140, 1000, 140, 1200, 200);
    canvas.drawPath(
      firstWave,
      Paint()
        ..color = WashijColors.mutedSky.withValues(alpha: .5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    final secondWave = Path()
      ..moveTo(0, 235)
      ..cubicTo(250, 190, 450, 280, 700, 225)
      ..cubicTo(900, 190, 1050, 190, 1200, 240);
    canvas.drawPath(
      secondWave,
      Paint()
        ..color = WashijColors.indigo.withValues(alpha: .9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    final ground = Path()
      ..moveTo(0, 270)
      ..cubicTo(300, 240, 600, 290, 1200, 255)
      ..lineTo(1200, 300)
      ..lineTo(0, 300)
      ..close();
    canvas.drawPath(ground, Paint()..color = WashijColors.midnight);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _NightSkyPainter oldDelegate) => false;
}
