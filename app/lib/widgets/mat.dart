import 'package:flutter/material.dart';

import '../data/models/artwork.dart';
import '../theme/tokens.dart';

class ArtworkMat extends StatelessWidget {
  const ArtworkMat({
    super.key,
    required this.artwork,
    this.aspectRatio,
    this.cornerMarks = false,
    this.padding = 16,
  });

  final Artwork artwork;
  final double? aspectRatio;
  final bool cornerMarks;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final image = artwork.image;
    if (image == null) {
      return AspectRatio(
        aspectRatio: aspectRatio ?? 4 / 3,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: WashijColors.nightRaised,
            border: Border.fromBorderSide(
              BorderSide(color: WashijColors.hairline),
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    artwork.titleAr,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, height: 1.2),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'الصورة غير معروضة لأن حقوقها محفوظة',
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: WashijColors.mist,
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final ratio = aspectRatio ?? image.width / image.height;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: WashijColors.nightRaised,
        border: Border.fromBorderSide(BorderSide(color: WashijColors.hairline)),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: AspectRatio(
          aspectRatio: ratio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                image.asset,
                fit: BoxFit.contain,
                semanticLabel: '${artwork.titleAr}، ${artwork.titleOrig}',
              ),
              if (image.remoteUrl case final url?)
                Image.network(
                  url,
                  fit: BoxFit.contain,
                  semanticLabel: '${artwork.titleAr}، ${artwork.titleOrig}',
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) =>
                          frame != null || wasSynchronouslyLoaded
                          ? child
                          : const SizedBox.shrink(),
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              if (cornerMarks)
                const IgnorePointer(
                  child: CustomPaint(painter: CornerMarksPainter()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CornerMarksPainter extends CustomPainter {
  const CornerMarksPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const length = 18.0;
    const inset = 2.0;
    final paint = Paint()
      ..color = WashijColors.ivory.withValues(alpha: 0.72)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final marks = [
      (Offset(inset, inset), Offset(length, inset), Offset(inset, length)),
      (
        Offset(size.width - inset, inset),
        Offset(size.width - length, inset),
        Offset(size.width - inset, length),
      ),
      (
        Offset(inset, size.height - inset),
        Offset(length, size.height - inset),
        Offset(inset, size.height - length),
      ),
      (
        Offset(size.width - inset, size.height - inset),
        Offset(size.width - length, size.height - inset),
        Offset(size.width - inset, size.height - length),
      ),
    ];
    for (final (corner, horizontal, vertical) in marks) {
      canvas.drawLine(corner, horizontal, paint);
      canvas.drawLine(corner, vertical, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CornerMarksPainter oldDelegate) => false;
}
