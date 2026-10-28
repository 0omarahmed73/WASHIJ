import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/art_reading.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/art_reading_card.dart';
import '../widgets/museum_page.dart';
import '../widgets/page_width.dart';
import '../widgets/section_header.dart';

class ReadingsPage extends ConsumerWidget {
  const ReadingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readings = ref.watch(artReadingsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: MuseumPage(
        slivers: [
          const SliverToBoxAdapter(child: PageWidth(child: _ReadingsIntro())),
          readings.when(
            data: (value) => SliverToBoxAdapter(
              child: PageWidth(child: _ReadingsContent(readings: value)),
            ),
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: PageWidth(
                child: _ReadingsStatus(
                  message: 'جارٍ تحميل القراءات الفنية',
                  loading: true,
                ),
              ),
            ),
            error: (error, stackTrace) => SliverFillRemaining(
              hasScrollBody: false,
              child: PageWidth(
                child: _ReadingsStatus(
                  message: 'تعذّر تحميل القراءات الفنية.',
                  onRetry: () => ref.invalidate(artReadingsProvider),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingsIntro extends StatelessWidget {
  const _ReadingsIntro();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 48, bottom: 24),
    child: Align(
      alignment: Alignment.topRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(title: 'قراءات عن الفن'),
              Text(
                'قراءات فنية من مواقع ونشرات عربية، مع مقتطفات قصيرة وروابط مباشرة إلى المقالات الأصلية.',
                style: WashijTypography.textTheme.bodyLarge?.copyWith(
                  color: WashijColors.mist,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ReadingsContent extends StatelessWidget {
  const _ReadingsContent({required this.readings});

  final List<ArtReading> readings;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 56),
    child: Align(
      alignment: Alignment.topRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: SizedBox(
          width: double.infinity,
          child: readings.isEmpty
              ? const _EmptyReadings()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var index = 0; index < readings.length; index++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: index == readings.length - 1 ? 0 : 16,
                        ),
                        child: ArtReadingCard(reading: readings[index]),
                      ),
                  ],
                ),
        ),
      ),
    ),
  );
}

class _ReadingsStatus extends StatelessWidget {
  const _ReadingsStatus({
    required this.message,
    this.loading = false,
    this.onRetry,
  });

  final String message;
  final bool loading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading)
            Semantics(
              label: 'جارٍ التحميل',
              child: SizedBox.square(
                dimension: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            const Icon(Icons.error_outline, color: WashijColors.danger),
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

class _EmptyReadings extends StatelessWidget {
  const _EmptyReadings();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: const BoxDecoration(
      color: WashijColors.deepBlue,
      border: Border.fromBorderSide(BorderSide(color: WashijColors.hairline)),
    ),
    child: const Text(
      'لا توجد قراءات متاحة الآن.',
      style: TextStyle(color: WashijColors.mist),
    ),
  );
}
