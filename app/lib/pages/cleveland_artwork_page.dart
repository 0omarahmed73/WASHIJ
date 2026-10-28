import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models/cleveland_artwork.dart';
import '../data/models/shareable_painting.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/museum_page.dart';
import '../widgets/page_width.dart';
import '../widgets/painting_actions.dart';
import '../widgets/painting_image_loading.dart';
import '../widgets/painting_lightbox.dart';

class ClevelandArtworkPage extends ConsumerWidget {
  const ClevelandArtworkPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artwork = ref.watch(clevelandArtworkProvider(id));
    return MuseumPage(
      slivers: [
        SliverToBoxAdapter(
          child: PageWidth(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(top: 36, bottom: 56),
              child: artwork.when(
                data: (value) => value == null
                    ? const _ClevelandStatus(
                        icon: Icons.image_not_supported_outlined,
                        message: 'لم نعثر على هذه اللوحة في بيانات المتحف.',
                      )
                    : _ClevelandArtworkContent(artwork: value),
                loading: () => const _ClevelandStatus(
                  icon: Icons.hourglass_top,
                  message: 'جارٍ تحميل بيانات اللوحة',
                  loading: true,
                ),
                error: (error, stackTrace) => _ClevelandStatus(
                  icon: Icons.error_outline,
                  message: 'تعذّر تحميل بيانات اللوحة.',
                  onRetry: () => ref.invalidate(clevelandArtworkProvider(id)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ClevelandArtworkContent extends StatelessWidget {
  const _ClevelandArtworkContent({required this.artwork});

  final ClevelandArtwork artwork;

  @override
  Widget build(BuildContext context) {
    final arabicTitle = artwork.titleArabic?.trim();
    final hasArabicTitle = arabicTitle != null && arabicTitle.isNotEmpty;

    return Align(
      alignment: Alignment.topRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1040),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'بيانات من متحف كليفلاند للفنون',
              style: TextStyle(color: WashijColors.mutedSky),
            ),
            const SizedBox(height: 12),
            if (hasArabicTitle)
              Text(
                arabicTitle,
                style: WashijTypography.textTheme.displayMedium,
              ),
            Text(
              artwork.title,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.right,
              style: WashijTypography.englishDisplay.copyWith(
                fontSize: hasArabicTitle ? 24 : 36,
                letterSpacing: 0,
                color: hasArabicTitle ? WashijColors.mist : WashijColors.ivory,
              ),
            ),
            if (!hasArabicTitle) ...[
              const SizedBox(height: 8),
              const Text(
                'لم يتوفر عنوان عربي مطابق في ويكي بيانات؛ يظهر العنوان الأصلي كما أورده المتحف.',
                style: TextStyle(color: WashijColors.mist),
              ),
            ],
            const SizedBox(height: 28),
            Container(
              constraints: const BoxConstraints(maxHeight: 620),
              decoration: const BoxDecoration(
                color: WashijColors.nightRaised,
                border: Border.fromBorderSide(
                  BorderSide(color: WashijColors.hairline),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => showPaintingLightbox(
                  context,
                  ShareablePainting.fromCleveland(artwork),
                ),
                child: Image.network(
                  artwork.imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: paintingImageLoadingBuilder,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    height: 320,
                    child: Center(
                      child: Text(
                        'تعذّر تحميل الصورة. تبقى بيانات المصدر متاحة أدناه.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: WashijColors.mist),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            PaintingActions(painting: ShareablePainting.fromCleveland(artwork)),
            const SizedBox(height: 28),
            Text(
              artwork.artistDisplay,
              style: WashijTypography.textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 24,
              runSpacing: 20,
              children: [
                _Fact(label: 'رقم السجل', value: artwork.accessionNumber),
                _Fact(label: 'التاريخ', value: artwork.dateDisplay),
                _Fact(label: 'الخامة', value: artwork.mediumDisplay),
                _Fact(label: 'الأبعاد', value: artwork.dimensions),
              ],
            ),
            const SizedBox(height: 32),
            const Divider(color: WashijColors.hairline),
            const SizedBox(height: 16),
            const Text(
              'الصورة موسومة برخصة CC0 في سجل المتحف. بيانات العمل مصدرية، وليست نصًا تحريريًا من وَشيج.',
              style: TextStyle(color: WashijColors.mist),
            ),
            if (artwork.creditLine.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'سطر الإحالة: ${artwork.creditLine}',
                style: const TextStyle(color: WashijColors.mist),
              ),
            ],
            const SizedBox(height: 20),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton.icon(
                onPressed: () => _openSource(context, artwork.sourceUrl),
                icon: const Icon(Icons.open_in_new),
                label: const Text('سجل اللوحة في موقع المتحف'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSource(BuildContext context, String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        uri.scheme != 'https' ||
        !{'clevelandart.org', 'www.clevelandart.org'}.contains(uri.host)) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('رابط سجل المتحف غير صالح.')),
      );
      return;
    }
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        ScaffoldMessenger.maybeOf(
          context,
        )?.showSnackBar(const SnackBar(content: Text('تعذّر فتح سجل المتحف.')));
      }
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.maybeOf(
          context,
        )?.showSnackBar(const SnackBar(content: Text('تعذّر فتح سجل المتحف.')));
      }
    }
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: WashijColors.mutedSky)),
          const SizedBox(height: 5),
          Text(value, style: WashijTypography.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ClevelandStatus extends StatelessWidget {
  const _ClevelandStatus({
    required this.icon,
    required this.message,
    this.loading = false,
    this.onRetry,
  });

  final IconData icon;
  final String message;
  final bool loading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading)
            const CircularProgressIndicator(color: WashijColors.starYellow)
          else
            Icon(icon, color: WashijColors.danger),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ],
      ),
    ),
  );
}
