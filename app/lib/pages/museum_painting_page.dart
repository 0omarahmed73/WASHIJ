import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models/museum_painting.dart';
import '../data/models/shareable_painting.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/museum_page.dart';
import '../widgets/page_width.dart';
import '../widgets/painting_actions.dart';
import '../widgets/painting_image_loading.dart';
import '../widgets/painting_lightbox.dart';

class MuseumPaintingPage extends ConsumerWidget {
  const MuseumPaintingPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paintings = ref.watch(museumPaintingsProvider);
    return MuseumPage(
      slivers: [
        SliverToBoxAdapter(
          child: PageWidth(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(top: 36, bottom: 56),
              child: paintings.when(
                data: (items) {
                  for (final painting in items) {
                    if (painting.id == id) {
                      return _MuseumPaintingContent(painting: painting);
                    }
                  }
                  return const _MuseumPaintingStatus(
                    icon: Icons.image_not_supported_outlined,
                    message: 'لم نعثر على هذه اللوحة في البيانات المحلية.',
                  );
                },
                loading: () => const _MuseumPaintingStatus(
                  icon: Icons.hourglass_top,
                  message: 'جارٍ تحميل بيانات اللوحة',
                  loading: true,
                ),
                error: (error, stackTrace) => _MuseumPaintingStatus(
                  icon: Icons.error_outline,
                  message: 'تعذّر تحميل بيانات اللوحات.',
                  onRetry: () => ref.invalidate(museumPaintingsProvider),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MuseumPaintingContent extends StatelessWidget {
  const _MuseumPaintingContent({required this.painting});

  final MuseumPainting painting;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topRight,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1040),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'من ${painting.sourceNameArabic}',
            style: const TextStyle(color: WashijColors.mutedSky),
          ),
          const SizedBox(height: 12),
          Text(
            painting.titleArabic,
            style: WashijTypography.textTheme.displayMedium,
          ),
          Text(
            painting.title,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.right,
            style: WashijTypography.englishDisplay.copyWith(
              fontSize: 24,
              letterSpacing: 0,
              color: WashijColors.mist,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            constraints: const BoxConstraints(maxHeight: 620),
            decoration: const BoxDecoration(
              color: WashijColors.nightRaised,
              border: Border.fromBorderSide(
                BorderSide(color: WashijColors.hairline),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: painting.imageAsset == null && painting.imageUrl == null
                ? const SizedBox(
                    height: 280,
                    child: Center(
                      child: Text(
                        'لا تتوفر صورة لهذا السجل.',
                        style: TextStyle(color: WashijColors.mist),
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () => showPaintingLightbox(
                      context,
                      ShareablePainting.fromMuseum(painting),
                    ),
                    child: painting.imageAsset != null
                        ? Image.asset(
                            painting.imageAsset!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox(
                                  height: 280,
                                  child: Center(
                                    child: Text(
                                      'تعذّر تحميل الصورة. تبقى بيانات المصدر متاحة أدناه.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: WashijColors.mist,
                                      ),
                                    ),
                                  ),
                                ),
                          )
                        : Image.network(
                            painting.imageUrl!,
                            fit: BoxFit.contain,
                            loadingBuilder: paintingImageLoadingBuilder,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox(
                                  height: 280,
                                  child: Center(
                                    child: Text(
                                      'تعذّر تحميل الصورة. تبقى بيانات المصدر متاحة أدناه.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: WashijColors.mist,
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                  ),
          ),
          const SizedBox(height: 16),
          PaintingActions(painting: ShareablePainting.fromMuseum(painting)),
          const SizedBox(height: 24),
          Text(
            painting.artistArabic,
            style: WashijTypography.textTheme.headlineMedium,
          ),
          Text(
            painting.artist,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.right,
            style: WashijTypography.textTheme.bodyMedium?.copyWith(
              color: WashijColors.mist,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 20,
            children: [
              _Fact(label: 'التاريخ', value: painting.dateArabic),
              _Fact(label: 'الخامة', value: painting.mediumArabic),
              _Fact(label: 'الأبعاد', value: painting.dimensions),
              _Fact(label: 'المكان', value: painting.originArabic),
            ],
          ),
          const SizedBox(height: 28),
          const _TranslationNotice(),
          const SizedBox(height: 24),
          Text(
            painting.descriptionArabic,
            style: WashijTypography.textTheme.bodyLarge?.copyWith(height: 1.8),
          ),
          const SizedBox(height: 32),
          const Divider(color: WashijColors.hairline),
          const SizedBox(height: 16),
          Text(
            'إحالة النص: ${painting.sourceNameArabic} · ${painting.licenceName}',
            style: const TextStyle(color: WashijColors.mist),
          ),
          if (painting.credit.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'سطر المتحف: ${painting.credit}',
              style: const TextStyle(color: WashijColors.mist),
            ),
          ],
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: () => _open(context, painting.sourceUrl),
                icon: const Icon(Icons.open_in_new),
                label: const Text('سجل اللوحة في موقع المتحف'),
              ),
              TextButton.icon(
                onPressed: () => _open(context, painting.licenceUrl),
                icon: const Icon(Icons.description_outlined),
                label: Text('رخصة ${painting.licenceName}'),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Future<void> _open(BuildContext context, String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme != 'https') return;
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('تعذّر فتح الرابط. حاول مرة أخرى.')),
        );
      }
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('تعذّر فتح الرابط. حاول مرة أخرى.')),
        );
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

class _TranslationNotice extends StatelessWidget {
  const _TranslationNotice();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: WashijColors.deepBlue,
      border: BorderDirectional(
        start: BorderSide(color: WashijColors.starYellow, width: 2),
      ),
    ),
    child: const Text(
      'هذه ترجمة عربية مصحّحة آليًا، لكنها لم تراجع تحريرياً بعد بواسطة محرر عربي أو مؤرخ فني.',
      style: TextStyle(color: WashijColors.mist),
    ),
  );
}

class _MuseumPaintingStatus extends StatelessWidget {
  const _MuseumPaintingStatus({
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
            Icon(icon, color: WashijColors.mist),
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
