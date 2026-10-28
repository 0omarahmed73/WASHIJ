import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models/artwork.dart';
import '../theme/tokens.dart';
import 'mat.dart';

void showArtworkLightbox(BuildContext context, Artwork artwork) {
  if (artwork.image == null) return;
  showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (dialogContext) => ArtworkLightbox(artwork: artwork),
  );
}

class ArtworkLightbox extends StatelessWidget {
  const ArtworkLightbox({super.key, required this.artwork});

  final Artwork artwork;

  @override
  Widget build(BuildContext context) {
    final image = artwork.image!;
    final ratio = image.width / image.height;
    final screen = MediaQuery.sizeOf(context);
    final maxWidth = math.min(screen.width - 40, 1100.0);
    final maxHeight = screen.height - 100;
    final width = math.min(maxWidth, maxHeight * ratio);
    final height = width / ratio;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).pop(),
      },
      child: Focus(
        autofocus: true,
        child: Dialog(
          backgroundColor: WashijColors.deepBlue,
          insetPadding: const EdgeInsets.all(20),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: WashijColors.borderControl),
          ),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: ArtworkMat(
                      artwork: artwork,
                      aspectRatio: ratio,
                      cornerMarks: true,
                      padding: 14,
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 4,
                  end: 4,
                  child: IconButton.filledTonal(
                    tooltip: 'إغلاق التكبير',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
