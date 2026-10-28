import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models/shareable_painting.dart';
import '../theme/tokens.dart';
import 'mat.dart';

/// Opens the whole painting in the same framed zoom container the curated
/// works use (see `lightbox.dart`): a square dialog, a mat with corner marks,
/// pinch and wheel zoom up to 4 times, and a close button. The painting is
/// never cropped, tinted or filtered.
void showPaintingLightbox(BuildContext context, ShareablePainting painting) {
  if (!painting.hasImage) return;
  showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (dialogContext) => PaintingLightbox(painting: painting),
  );
}

class PaintingLightbox extends StatefulWidget {
  const PaintingLightbox({super.key, required this.painting});

  final ShareablePainting painting;

  @override
  State<PaintingLightbox> createState() => _PaintingLightboxState();
}

class _PaintingLightboxState extends State<PaintingLightbox> {
  late final ImageProvider _provider = widget.painting.imageAsset != null
      ? AssetImage(widget.painting.imageAsset!)
      : NetworkImage(widget.painting.imageUrl!);
  late final Future<double?> _ratio = _resolveRatio();

  /// The container is sized to the painting, so its shape is read first.
  Future<double?> _resolveRatio() {
    final completer = Completer<double?>();
    final stream = _provider.resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        if (!completer.isCompleted) {
          completer.complete(info.image.width / info.image.height);
        }
        stream.removeListener(listener);
      },
      onError: (Object error, StackTrace? stackTrace) {
        if (!completer.isCompleted) completer.complete(null);
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final painting = widget.painting;
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
          child: FutureBuilder<double?>(
            future: _ratio,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  width: 240,
                  height: 240,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: WashijColors.starYellow,
                    ),
                  ),
                );
              }
              final ratio = snapshot.data;
              if (ratio == null) {
                return SizedBox(
                  width: 280,
                  height: 200,
                  child: Stack(
                    children: [
                      const Center(
                        child: Text(
                          'تعذّر تحميل الصورة.',
                          style: TextStyle(color: WashijColors.mist),
                        ),
                      ),
                      _closeButton(context),
                    ],
                  ),
                );
              }
              final screen = MediaQuery.sizeOf(context);
              final maxWidth = math.min(screen.width - 40, 1100.0);
              final maxHeight = screen.height - 100;
              final width = math.min(maxWidth, maxHeight * ratio);
              final height = width / ratio;
              return SizedBox(
                width: width,
                height: height,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            color: WashijColors.nightRaised,
                            border: Border.fromBorderSide(
                              BorderSide(color: WashijColors.hairline),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image(
                                  image: _provider,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                  semanticLabel: painting.titleArabic,
                                ),
                                const IgnorePointer(
                                  child: CustomPaint(
                                    painter: CornerMarksPainter(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    _closeButton(context),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _closeButton(BuildContext context) => PositionedDirectional(
    top: 4,
    end: 4,
    child: IconButton.filledTonal(
      tooltip: 'إغلاق التكبير',
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.close),
    ),
  );
}
