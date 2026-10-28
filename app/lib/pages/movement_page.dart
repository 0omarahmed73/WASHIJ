import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog.dart';
import '../data/models/artist.dart';
import '../data/models/movement.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/artwork_card.dart';
import '../widgets/museum_page.dart';
import '../widgets/page_width.dart';
import '../widgets/section_header.dart';
import '../widgets/focus_ring.dart';

class MovementPage extends ConsumerWidget {
  const MovementPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MuseumPage(
        slivers: [
          catalog.when(
            data: (value) {
              final movement = value.movements[id];
              return SliverToBoxAdapter(
                child: PageWidth(
                  child: movement == null
                      ? const _MovementNotFound()
                      : _MovementDetail(catalog: value, movement: movement),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: _CatalogStatus(
                message: 'جارٍ تحميل المدرسة الفنية',
                loading: true,
              ),
            ),
            error: (error, stackTrace) => SliverFillRemaining(
              hasScrollBody: false,
              child: _CatalogStatus(
                message: 'تعذّر تحميل المدرسة الفنية.',
                onRetry: () => ref.invalidate(catalogProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MovementDetail extends StatelessWidget {
  const _MovementDetail({required this.catalog, required this.movement});

  final Catalog catalog;
  final Movement movement;

  @override
  Widget build(BuildContext context) {
    final artists = catalog.artists.values
        .where((artist) => artist.movementIds.contains(movement.id))
        .toList(growable: false);
    final works = catalog.worksInMovement(movement.id);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () => context.go('/movements'),
              child: const Text('المدارس الفنية'),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            movement.nameAr,
            style: WashijTypography.textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            movement.nameOrig,
            textDirection: TextDirection.ltr,
            style: WashijTypography.englishDisplay,
          ),
          if (movement.line.isNotEmpty) ...[
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Text(
                movement.line,
                style: WashijTypography.textTheme.bodyLarge?.copyWith(
                  color: WashijColors.mutedSky,
                ),
              ),
            ),
          ],
          const SizedBox(height: 28),
          _MovementFacts(movement: movement),
          const SizedBox(height: 40),
          SectionHeader(title: 'عن المدرسة'),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Text(
              movement.intro.isEmpty
                  ? 'لا تتوفر مقدمة عن هذه المدرسة في هذا السجل.'
                  : movement.intro,
              style: WashijTypography.textTheme.bodyLarge?.copyWith(
                color: movement.intro.isEmpty
                    ? WashijColors.mist
                    : WashijColors.ivory,
              ),
            ),
          ),
          const SizedBox(height: 40),
          SectionHeader(title: 'سمات فنية'),
          if (movement.traits.isEmpty)
            const _EmptyState(message: 'لا توجد سمات مسجلة لهذه المدرسة.')
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final trait in movement.traits)
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 44),
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: WashijColors.deepBlue,
                        border: Border.fromBorderSide(
                          BorderSide(color: WashijColors.borderControl),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Text(trait),
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 40),
          SectionHeader(title: 'فنانون مرتبطون بها'),
          if (artists.isEmpty)
            const _EmptyState(
              message: 'لا توجد أسماء فنانين مرتبطة بهذه المدرسة.',
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 960
                    ? 3
                    : constraints.maxWidth >= 600
                    ? 2
                    : 1;
                const gap = 20.0;
                final width =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final artist in artists)
                      SizedBox(
                        width: width,
                        child: _ArtistLinkCard(artist: artist),
                      ),
                  ],
                );
              },
            ),
          const SizedBox(height: 40),
          SectionHeader(title: 'أعمال من المدرسة'),
          if (works.isEmpty)
            const _EmptyState(message: 'لا توجد أعمال مسجلة لهذه المدرسة.')
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 960
                    ? 3
                    : constraints.maxWidth >= 600
                    ? 2
                    : 1;
                const gap = 20.0;
                final width =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final work in works)
                      if (catalog.artists[work.artistId] case final artist?)
                        SizedBox(
                          width: width,
                          child: ArtworkCard(artwork: work, artist: artist),
                        ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _MovementFacts extends StatelessWidget {
  const _MovementFacts({required this.movement});

  final Movement movement;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: WashijColors.deepBlue,
      border: Border.fromBorderSide(BorderSide(color: WashijColors.hairline)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (movement.period.isNotEmpty)
          _FactRow(label: 'الفترة', value: movement.period),
        if (movement.place.isNotEmpty) ...[
          if (movement.period.isNotEmpty) const SizedBox(height: 12),
          _FactRow(label: 'المكان', value: movement.place),
        ],
      ],
    ),
  );
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 96,
        child: Text(label, style: const TextStyle(color: WashijColors.mist)),
      ),
      Expanded(child: Text(value)),
    ],
  );
}

class _ArtistLinkCard extends StatelessWidget {
  const _ArtistLinkCard({required this.artist});

  final Artist artist;

  @override
  Widget build(BuildContext context) => Semantics(
    link: true,
    label: 'سيرة ${artist.nameAr}، ${artist.nameOrig}',
    child: Material(
      color: WashijColors.deepBlue,
      child: Ink(
        decoration: const BoxDecoration(
          border: Border.fromBorderSide(
            BorderSide(color: WashijColors.hairline),
          ),
        ),
        child: FocusRing(
          child: InkWell(
            onTap: () =>
                context.push('/artist/${Uri.encodeComponent(artist.id)}'),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    artist.nameAr,
                    style: WashijTypography.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    artist.nameOrig,
                    textDirection: TextDirection.ltr,
                    style: WashijTypography.englishDisplay.copyWith(
                      color: WashijColors.mist,
                      fontSize: 21,
                    ),
                  ),
                  if (artist.born.isNotEmpty || artist.died.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      [
                        artist.born,
                        artist.died,
                      ].where((year) => year.isNotEmpty).join(' – '),
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(color: WashijColors.mutedSky),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _MovementNotFound extends StatelessWidget {
  const _MovementNotFound();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 80),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'لم نعثر على المدرسة الفنية المطلوبة.',
            textAlign: TextAlign.center,
            style: WashijTypography.textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => context.go('/movements'),
            child: const Text('العودة إلى دليل المدارس الفنية'),
          ),
        ],
      ),
    ),
  );
}

class _CatalogStatus extends StatelessWidget {
  const _CatalogStatus({
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
      padding: const EdgeInsets.all(24),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: WashijColors.deepBlue,
      border: Border.fromBorderSide(BorderSide(color: WashijColors.hairline)),
    ),
    child: Text(message, style: const TextStyle(color: WashijColors.mist)),
  );
}
