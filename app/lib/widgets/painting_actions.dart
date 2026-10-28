import 'package:flutter/material.dart';

import '../data/models/shareable_painting.dart';
import '../data/painting_export.dart';
import '../theme/tokens.dart';
import 'painting_lightbox.dart';

/// Zoom, download and share controls for a painting's image and card.
class PaintingActions extends StatefulWidget {
  const PaintingActions({
    super.key,
    required this.painting,
    this.export = const PaintingExport(),
    this.showZoom = true,
  });

  final ShareablePainting painting;
  final PaintingExport export;

  /// Hide the zoom button when the page already has its own.
  final bool showZoom;

  @override
  State<PaintingActions> createState() => _PaintingActionsState();
}

class _PaintingActionsState extends State<PaintingActions> {
  String? _busy;

  Future<void> _run(
    String key,
    String success,
    Future<void> Function() action,
  ) async {
    setState(() => _busy = key);
    try {
      await action();
      if (mounted && success.isNotEmpty) {
        _message(success);
      }
    } on Object {
      if (mounted)
        _message('تعذّر إكمال العملية. تحقق من الاتصال وحاول مرة أخرى.');
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(SnackBar(content: Text(text)));

  Rect? _origin() {
    final box = context.findRenderObject();
    return box is RenderBox && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
  }

  String get _shareText =>
      'لوحة «${widget.painting.titleArabic}» ${widget.painting.artistArabic}. '
      'كل لوحة خيط في حكاية الفن. ${widget.painting.attribution}';

  Future<void> _saveImage() async {
    final file = await widget.export.loadImage(widget.painting);
    await widget.export.save(
      name: widget.painting.fileStem,
      bytes: file.bytes,
      extension: file.extension,
      mimeType: file.mimeType,
    );
  }

  Future<void> _shareImage() async {
    final origin = _origin();
    final file = await widget.export.loadImage(widget.painting);
    await widget.export.share(
      title: widget.painting.titleArabic,
      text: _shareText,
      fileName: '${widget.painting.fileStem}.${file.extension}',
      bytes: file.bytes,
      mimeType: file.mimeType,
      origin: origin,
    );
  }

  Future<void> _card({required bool share}) async {
    final origin = _origin();
    final file = await widget.export.loadImage(widget.painting);
    final png = await widget.export.renderCard(widget.painting, file.bytes);
    if (share) {
      await widget.export.share(
        title: 'بطاقة لوحة ${widget.painting.titleArabic}',
        text: _shareText,
        fileName: '${widget.painting.fileStem}-card.png',
        bytes: png,
        mimeType: 'image/png',
        origin: origin,
      );
    } else {
      await widget.export.save(
        name: '${widget.painting.fileStem}-card',
        bytes: png,
        extension: 'png',
        mimeType: 'image/png',
      );
    }
  }

  Widget _button({
    required String key,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    final working = _busy == key;
    return OutlinedButton.icon(
      onPressed: _busy == null ? onPressed : null,
      style:
          OutlinedButton.styleFrom(
            foregroundColor: WashijColors.ivory,
            side: const BorderSide(color: WashijColors.borderControl),
            minimumSize: const Size(48, 48),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ).copyWith(
            side: washijFocusSide(
              const BorderSide(color: WashijColors.borderControl),
            ),
          ),
      icon: working
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: WashijColors.starYellow,
              ),
            )
          : Icon(icon),
      label: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.painting.hasImage) return const SizedBox.shrink();
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (widget.showZoom)
          _button(
            key: 'zoom',
            icon: Icons.zoom_in,
            label: 'تكبير الصورة',
            onPressed: () => showPaintingLightbox(context, widget.painting),
          ),
        _button(
          key: 'save-image',
          icon: Icons.download_outlined,
          label: 'تنزيل الصورة',
          onPressed: () => _run(
            'save-image',
            'تم حفظ الصورة في مجلد التنزيلات (WASHIJ).',
            _saveImage,
          ),
        ),
        _button(
          key: 'share-image',
          icon: Icons.ios_share_outlined,
          label: 'مشاركة الصورة',
          onPressed: () => _run('share-image', '', _shareImage),
        ),
        _button(
          key: 'save-card',
          icon: Icons.image_outlined,
          label: 'تنزيل البطاقة',
          onPressed: () => _run(
            'save-card',
            'تم حفظ البطاقة في مجلد التنزيلات (WASHIJ).',
            () => _card(share: false),
          ),
        ),
        _button(
          key: 'share-card',
          icon: Icons.share_outlined,
          label: 'مشاركة البطاقة',
          onPressed: () => _run('share-card', '', () => _card(share: true)),
        ),
      ],
    );
  }
}
