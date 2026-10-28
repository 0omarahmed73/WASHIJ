import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../data/models/artist.dart';
import '../data/models/artwork.dart';
import '../paint/logo_symbol.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

class ArtworkShareCard extends StatefulWidget {
  const ArtworkShareCard({
    super.key,
    required this.artwork,
    required this.artist,
  });

  final Artwork artwork;
  final Artist artist;

  @override
  State<ArtworkShareCard> createState() => _ArtworkShareCardState();
}

class _ArtworkShareCardState extends State<ArtworkShareCard> {
  bool _isSharing = false;

  Future<void> _share() async {
    setState(() => _isSharing = true);
    try {
      final png = await _renderCard();
      if (!mounted) return;

      final fileName = _fileName(widget.artwork.id);
      final renderObject = context.findRenderObject();
      final sharePositionOrigin =
          renderObject is RenderBox && renderObject.hasSize
          ? renderObject.localToGlobal(Offset.zero) & renderObject.size
          : null;
      await SharePlus.instance.share(
        ShareParams(
          title: 'بطاقة لوحة ${widget.artwork.titleAr}',
          text:
              'لوحة «${widget.artwork.titleAr}» للفنان ${widget.artist.nameAr}، ${widget.artwork.year}. كل لوحة خيط في حكاية الفن.',
          files: [XFile.fromData(png, name: fileName, mimeType: 'image/png')],
          fileNameOverrides: [fileName],
          sharePositionOrigin: sharePositionOrigin,
          downloadFallbackEnabled: true,
        ),
      );
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذّر تجهيز بطاقة المشاركة. حاول مرة أخرى.'),
            backgroundColor: WashijColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<Uint8List> _renderCard() async {
    ui.Image? painting;
    ui.Picture? picture;
    ui.Image? card;
    try {
      painting = await _loadPainting();
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      _paintCard(canvas, painting);
      picture = recorder.endRecording();
      card = await picture.toImage(1080, 1350);
      final data = await card.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('PNG encoding returned no data');
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } finally {
      painting?.dispose();
      picture?.dispose();
      card?.dispose();
    }
  }

  Future<ui.Image?> _loadPainting() async {
    final image = widget.artwork.image;
    if (image == null) return null;

    final remoteUrl = image.remoteUrl;
    if (remoteUrl != null && remoteUrl.trim().isNotEmpty) {
      try {
        return await _decodeImage(NetworkImage(remoteUrl));
      } on Object {
        // Match the artwork mat: keep the bundled image as the offline fallback.
      }
    }

    try {
      return await _decodeImage(AssetImage(image.asset));
    } on Object {
      return null;
    }
  }

  Future<ui.Image> _decodeImage(ImageProvider<Object> provider) async {
    final stream = provider.resolve(const ImageConfiguration());
    final completer = Completer<ui.Image>();
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        if (!completer.isCompleted) completer.complete(info.image.clone());
      },
      onError: (Object error, StackTrace? stackTrace) {
        if (!completer.isCompleted) completer.completeError(error, stackTrace);
      },
    );
    stream.addListener(listener);
    try {
      return await completer.future.timeout(const Duration(seconds: 20));
    } finally {
      stream.removeListener(listener);
    }
  }

  void _paintCard(Canvas canvas, ui.Image? painting) {
    const size = Size(1080, 1350);
    const frame = Rect.fromLTWH(44, 44, 992, 1262);
    canvas.drawRect(Offset.zero & size, Paint()..color = WashijColors.midnight);
    canvas.drawRect(
      frame,
      Paint()
        ..color = WashijColors.hairline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.save();
    canvas.translate(922, 58);
    const LogoSymbolPainter().paint(canvas, const Size(82, 82));
    canvas.restore();
    _drawText(
      canvas,
      text: 'وَشيج',
      bounds: const Rect.fromLTWH(610, 46, 286, 58),
      style: const TextStyle(
        color: WashijColors.ivory,
        fontFamily: WashijFonts.wordmark,
        fontSize: 49,
        fontWeight: FontWeight.w700,
      ),
    );
    _drawText(
      canvas,
      text: 'كل لوحة خيط في حكاية الفن',
      bounds: const Rect.fromLTWH(535, 126, 360, 35),
      style: const TextStyle(
        color: WashijColors.mutedSky,
        fontFamily: WashijFonts.ui,
        fontSize: 20,
      ),
    );

    const mat = Rect.fromLTWH(72, 188, 936, 660);
    canvas.drawRect(mat, Paint()..color = WashijColors.nightRaised);
    canvas.drawRect(
      mat,
      Paint()
        ..color = WashijColors.hairline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _paintCornerMarks(canvas, mat);

    if (painting == null) {
      _paintTypographicArtwork(canvas, mat);
    } else {
      _paintWholePainting(canvas, painting, mat.deflate(26));
    }

    final hasPainting = painting != null;
    if (hasPainting) {
      _drawText(
        canvas,
        text: widget.artwork.titleAr,
        bounds: const Rect.fromLTWH(92, 868, 896, 112),
        style: const TextStyle(
          color: WashijColors.ivory,
          fontFamily: WashijFonts.heading,
          fontSize: 50,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        maxLines: 2,
      );
      _drawText(
        canvas,
        text: widget.artwork.titleOrig,
        bounds: const Rect.fromLTWH(92, 984, 896, 54),
        style: const TextStyle(
          color: WashijColors.mist,
          fontFamily: WashijFonts.englishDisplay,
          fontSize: 31,
          fontWeight: FontWeight.w500,
        ),
        direction: TextDirection.ltr,
        align: TextAlign.left,
      );
    }

    _drawText(
      canvas,
      text: widget.artist.nameAr,
      bounds: Rect.fromLTWH(92, hasPainting ? 1036 : 876, 896, 52),
      style: const TextStyle(
        color: WashijColors.ivory,
        fontFamily: WashijFonts.reading,
        fontSize: 31,
        fontWeight: FontWeight.w700,
      ),
    );
    _drawText(
      canvas,
      text: '${widget.artist.nameOrig}  ·  ${widget.artwork.year}',
      bounds: Rect.fromLTWH(92, hasPainting ? 1106 : 946, 896, 42),
      style: const TextStyle(
        color: WashijColors.mist,
        fontFamily: WashijFonts.englishDisplay,
        fontSize: 26,
        fontWeight: FontWeight.w500,
      ),
      direction: TextDirection.ltr,
      align: TextAlign.left,
    );

    final credit = widget.artwork.credit;
    final creditDetails = [
      credit.author.trim(),
      credit.licence.trim(),
    ].where((value) => value.isNotEmpty).join(' · ');
    final creditLine = creditDetails.isEmpty
        ? credit.attribution
        : 'اعتماد الصورة: $creditDetails';
    _drawText(
      canvas,
      text: creditLine,
      bounds: Rect.fromLTWH(92, hasPainting ? 1186 : 1046, 896, 34),
      style: const TextStyle(
        color: WashijColors.mist,
        fontFamily: WashijFonts.ui,
        fontSize: 17,
      ),
      maxLines: 1,
    );
    if (credit.attribution.trim().isNotEmpty &&
        credit.attribution != creditLine) {
      _drawText(
        canvas,
        text: credit.attribution,
        bounds: Rect.fromLTWH(92, hasPainting ? 1224 : 1084, 896, 46),
        style: const TextStyle(
          color: WashijColors.mutedSky,
          fontFamily: WashijFonts.ui,
          fontSize: 17,
        ),
        direction: TextDirection.ltr,
        align: TextAlign.left,
        maxLines: 2,
      );
    }
  }

  void _paintWholePainting(Canvas canvas, ui.Image image, Rect bounds) {
    final sourceSize = Size(image.width.toDouble(), image.height.toDouble());
    final fitted = applyBoxFit(BoxFit.contain, sourceSize, bounds.size);
    final source = Alignment.center.inscribe(
      fitted.source,
      Offset.zero & sourceSize,
    );
    final destination = Alignment.center.inscribe(fitted.destination, bounds);
    canvas.save();
    canvas.clipRect(bounds);
    canvas.drawImageRect(
      image,
      source,
      destination,
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.restore();
  }

  void _paintTypographicArtwork(Canvas canvas, Rect mat) {
    _drawText(
      canvas,
      text: widget.artwork.titleAr,
      bounds: Rect.fromLTWH(mat.left + 54, mat.top + 154, mat.width - 108, 132),
      style: const TextStyle(
        color: WashijColors.ivory,
        fontFamily: WashijFonts.heading,
        fontSize: 64,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      maxLines: 2,
    );
    _drawText(
      canvas,
      text: widget.artwork.titleOrig,
      bounds: Rect.fromLTWH(mat.left + 54, mat.top + 300, mat.width - 108, 62),
      style: const TextStyle(
        color: WashijColors.mist,
        fontFamily: WashijFonts.englishDisplay,
        fontSize: 35,
        fontWeight: FontWeight.w500,
      ),
      direction: TextDirection.ltr,
      align: TextAlign.center,
    );
    _drawText(
      canvas,
      text: 'الصورة غير متاحة؛ صُممت البطاقة لتحتفي بالعمل وعنوانه.',
      bounds: Rect.fromLTWH(
        mat.left + 72,
        mat.bottom - 148,
        mat.width - 144,
        60,
      ),
      style: const TextStyle(
        color: WashijColors.mutedSky,
        fontFamily: WashijFonts.ui,
        fontSize: 20,
      ),
      align: TextAlign.center,
      maxLines: 2,
    );
  }

  void _paintCornerMarks(Canvas canvas, Rect rect) {
    const length = 22.0;
    const inset = 12.0;
    final paint = Paint()
      ..color = WashijColors.ivory.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final left = rect.left + inset;
    final right = rect.right - inset;
    final top = rect.top + inset;
    final bottom = rect.bottom - inset;
    for (final (x, y, horizontal, vertical) in [
      (left, top, length, length),
      (right, top, -length, length),
      (left, bottom, length, -length),
      (right, bottom, -length, -length),
    ]) {
      canvas.drawLine(Offset(x, y), Offset(x + horizontal, y), paint);
      canvas.drawLine(Offset(x, y), Offset(x, y + vertical), paint);
    }
  }

  void _drawText(
    Canvas canvas, {
    required String text,
    required Rect bounds,
    required TextStyle style,
    TextDirection direction = TextDirection.rtl,
    TextAlign align = TextAlign.right,
    int maxLines = 1,
  }) {
    if (text.trim().isEmpty) return;
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: direction,
      textAlign: align,
      maxLines: maxLines,
      ellipsis: '…',
    )..layout(maxWidth: bounds.width);
    final dy =
        bounds.top +
        ((bounds.height - painter.height) / 2).clamp(0.0, bounds.height);
    painter.paint(canvas, Offset(bounds.left, dy));
  }

  String _fileName(String id) {
    final safeId = id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    return 'washij-${safeId.isEmpty ? 'artwork' : safeId}.png';
  }

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: _isSharing ? null : _share,
    style:
        OutlinedButton.styleFrom(
          foregroundColor: WashijColors.ivory,
          side: const BorderSide(color: WashijColors.borderControl),
          minimumSize: const Size(48, 48),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 18,
            vertical: 12,
          ),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ).copyWith(
          side: washijFocusSide(
            const BorderSide(color: WashijColors.borderControl),
          ),
        ),
    icon: _isSharing
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: WashijColors.starYellow,
            ),
          )
        : const Icon(Icons.ios_share_outlined),
    label: Text(_isSharing ? 'جارٍ تجهيز البطاقة…' : 'مشاركة بطاقة اللوحة'),
  );
}
