import 'dart:async';
import 'dart:ui' as ui;

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

import '../paint/logo_symbol.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'models/shareable_painting.dart';

class PaintingImageFile {
  const PaintingImageFile({
    required this.bytes,
    required this.extension,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String extension;
  final String mimeType;
}

/// Loads, renders, saves and shares paintings. Nothing here changes a
/// painting's colours: the image bytes are passed through untouched and the
/// card draws the whole painting uncropped.
class PaintingExport {
  const PaintingExport({this.client});

  final http.Client? client;

  /// The original image when online, the bundled copy otherwise.
  Future<PaintingImageFile> loadImage(ShareablePainting painting) async {
    final url = painting.imageUrl;
    if (url != null) {
      try {
        final response = await (client ?? http.Client())
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 20));
        final type = response.headers['content-type'] ?? '';
        if (response.statusCode == 200 &&
            type.startsWith('image/') &&
            response.bodyBytes.isNotEmpty) {
          return PaintingImageFile(
            bytes: response.bodyBytes,
            extension: _extensionFor(type),
            mimeType: type.split(';').first,
          );
        }
      } on Object {
        // Fall back to the bundled copy below.
      }
    }
    final asset = painting.imageAsset;
    if (asset == null) {
      throw StateError('No image is available for ${painting.id}');
    }
    final data = await rootBundle.load(asset);
    return PaintingImageFile(
      bytes: data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      extension: 'webp',
      mimeType: 'image/webp',
    );
  }

  /// A 1080 × 1350 PNG card: the whole painting, titles, artist and credit.
  Future<Uint8List> renderCard(
    ShareablePainting painting,
    Uint8List? imageBytes,
  ) async {
    ui.Image? image;
    ui.Picture? picture;
    ui.Image? card;
    try {
      if (imageBytes != null) {
        final codec = await ui.instantiateImageCodec(imageBytes);
        image = (await codec.getNextFrame()).image;
        codec.dispose();
      }
      final recorder = ui.PictureRecorder();
      _paintCard(Canvas(recorder), painting, image);
      picture = recorder.endRecording();
      card = await picture.toImage(1080, 1350);
      final data = await card.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('PNG encoding returned no data');
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } finally {
      image?.dispose();
      picture?.dispose();
      card?.dispose();
    }
  }

  /// Saves to the public Downloads folder (Download/WASHIJ on Android), where
  /// the Files and Gallery apps can see it; the browser downloads it on web.
  /// iOS has no shared Downloads folder, so the file goes to the app's
  /// Documents folder.
  Future<void> save({
    required String name,
    required Uint8List bytes,
    required String extension,
    required String mimeType,
  }) async {
    final saver = FileSaver.instance;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      await saver.saveFile(
        name: name,
        bytes: bytes,
        fileExtension: extension,
        mimeType: MimeType.custom,
        customMimeType: mimeType,
      );
      return;
    }
    await saver.saveToDownloads(
      name: name,
      bytes: bytes,
      fileExtension: extension,
      mimeType: MimeType.custom,
      customMimeType: mimeType,
      subfolder: 'WASHIJ',
    );
  }

  Future<void> share({
    required String title,
    required String text,
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    Rect? origin,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        title: title,
        text: text,
        files: [XFile.fromData(bytes, name: fileName, mimeType: mimeType)],
        fileNameOverrides: [fileName],
        sharePositionOrigin: origin,
        downloadFallbackEnabled: true,
      ),
    );
  }

  static String _extensionFor(String contentType) {
    final type = contentType.toLowerCase();
    if (type.contains('png')) return 'png';
    if (type.contains('webp')) return 'webp';
    if (type.contains('gif')) return 'gif';
    return 'jpg';
  }

  void _paintCard(Canvas canvas, ShareablePainting painting, ui.Image? image) {
    const size = Size(1080, 1350);
    canvas.drawRect(Offset.zero & size, Paint()..color = WashijColors.midnight);
    canvas.drawRect(
      const Rect.fromLTWH(44, 44, 992, 1262),
      Paint()
        ..color = WashijColors.hairline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.save();
    canvas.translate(922, 58);
    const LogoSymbolPainter().paint(canvas, const Size(82, 82));
    canvas.restore();
    _text(
      canvas,
      'وَشيج',
      const Rect.fromLTWH(610, 46, 286, 58),
      const TextStyle(
        color: WashijColors.ivory,
        fontFamily: WashijFonts.wordmark,
        fontSize: 49,
        fontWeight: FontWeight.w700,
      ),
    );
    _text(
      canvas,
      'كل لوحة خيط في حكاية الفن',
      const Rect.fromLTWH(535, 126, 360, 35),
      const TextStyle(
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
    if (image != null) {
      _wholePainting(canvas, image, mat.deflate(26));
    }

    _text(
      canvas,
      painting.titleArabic,
      const Rect.fromLTWH(92, 868, 896, 112),
      const TextStyle(
        color: WashijColors.ivory,
        fontFamily: WashijFonts.heading,
        fontSize: 50,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      maxLines: 2,
    );
    if (painting.titleOriginal.isNotEmpty &&
        painting.titleOriginal != painting.titleArabic) {
      _text(
        canvas,
        painting.titleOriginal,
        const Rect.fromLTWH(92, 984, 896, 54),
        const TextStyle(
          color: WashijColors.mist,
          fontFamily: WashijFonts.englishDisplay,
          fontSize: 31,
          fontWeight: FontWeight.w500,
        ),
        direction: TextDirection.ltr,
        align: TextAlign.left,
      );
    }
    _text(
      canvas,
      painting.artistArabic,
      const Rect.fromLTWH(92, 1036, 896, 52),
      const TextStyle(
        color: WashijColors.ivory,
        fontFamily: WashijFonts.reading,
        fontSize: 31,
        fontWeight: FontWeight.w700,
      ),
    );
    final detail = [
      painting.artistOriginal,
      painting.dateText,
    ].where((value) => value.trim().isNotEmpty).join('  ·  ');
    _text(
      canvas,
      detail,
      const Rect.fromLTWH(92, 1106, 896, 42),
      const TextStyle(
        color: WashijColors.mist,
        fontFamily: WashijFonts.englishDisplay,
        fontSize: 26,
        fontWeight: FontWeight.w500,
      ),
      direction: TextDirection.ltr,
      align: TextAlign.left,
    );
    _text(
      canvas,
      painting.creditLine.isEmpty ? '' : 'سطر المتحف: ${painting.creditLine}',
      const Rect.fromLTWH(92, 1186, 896, 34),
      const TextStyle(
        color: WashijColors.mist,
        fontFamily: WashijFonts.ui,
        fontSize: 17,
      ),
    );
    _text(
      canvas,
      painting.attribution,
      const Rect.fromLTWH(92, 1224, 896, 46),
      const TextStyle(
        color: WashijColors.mutedSky,
        fontFamily: WashijFonts.ui,
        fontSize: 17,
      ),
      direction: TextDirection.ltr,
      align: TextAlign.left,
      maxLines: 2,
    );
  }

  void _wholePainting(Canvas canvas, ui.Image image, Rect bounds) {
    final source = Size(image.width.toDouble(), image.height.toDouble());
    final fitted = applyBoxFit(BoxFit.contain, source, bounds.size);
    canvas.save();
    canvas.clipRect(bounds);
    canvas.drawImageRect(
      image,
      Alignment.center.inscribe(fitted.source, Offset.zero & source),
      Alignment.center.inscribe(fitted.destination, bounds),
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.restore();
  }

  void _text(
    Canvas canvas,
    String text,
    Rect bounds,
    TextStyle style, {
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
}
