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

class ArtistPage extends ConsumerWidget {
  const ArtistPage({super.key, required this.id});

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
              final artist = value.artists[id];
              return SliverToBoxAdapter(
                child: PageWidth(
                  child: artist == null
                      ? const _ArtistNotFound()
                      : _ArtistDetail(catalog: value, artist: artist),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: _CatalogStatus(
                message: 'جارٍ تحميل سيرة الفنان',
                loading: true,
              ),
            ),
            error: (error, stackTrace) => SliverFillRemaining(
              hasScrollBody: false,
              child: _CatalogStatus(
                message: 'تعذّر تحميل سيرة الفنان.',
                onRetry: () => ref.invalidate(catalogProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtistDetail extends StatelessWidget {
  const _ArtistDetail({required this.catalog, required this.artist});

  final Catalog catalog;
  final Artist artist;

  @override
  Widget build(BuildContext context) {
    final movements = artist.movementIds
        .map((id) => catalog.movements[id])
        .whereType<Movement>()
        .toList(growable: false);
    final works = catalog.worksByArtist(artist.id);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () => context.go('/artists'),
              child: const Text('الفنانون'),
            ),
          ),
          const SizedBox(height: 16),
          Text(artist.nameAr, style: WashijTypography.textTheme.displayMedium),
          const SizedBox(height: 8),
          Text(
            artist.nameOrig,
            textDirection: TextDirection.ltr,
            style: WashijTypography.englishDisplay,
          ),
          const SizedBox(height: 28),
          _ArtistFacts(artist: artist),
          const SizedBox(height: 40),
          _NarrativeSection(
            title: 'نبذة عن الفنان',
            text: artist.bio,
            emptyMessage: 'لا تتوفر نبذة عن الفنان في هذا السجل.',
          ),
          const SizedBox(height: 32),
          _NarrativeSection(
            title: 'أسلوبه الفني',
            text: artist.style,
            emptyMessage: 'لا تتوفر معلومات عن الأسلوب في هذا السجل.',
          ),
          const SizedBox(height: 40),
          SectionHeader(title: 'المدارس الفنية'),
          if (movements.isEmpty)
            const _EmptyState(message: 'لا توجد مدرسة فنية مرتبطة بهذا الفنان.')
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 760 ? 2 : 1;
                const gap = 16.0;
                final width =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final movement in movements)
                      SizedBox(
                        width: width,
                        child: _MovementLinkCard(movement: movement),
                      ),
                  ],
                );
              },
            ),
          const SizedBox(height: 40),
          SectionHeader(title: 'أعمال الفنان'),
          if (works.isEmpty)
            const _EmptyState(message: 'لا توجد أعمال مسجلة لهذا الفنان.')
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
                      if (catalog.artists[work.artistId] case final owner?)
                        SizedBox(
                          width: width,
                          child: ArtworkCard(artwork: work, artist: owner),
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

class _ArtistFacts extends StatelessWidget {
  const _ArtistFacts({required this.artist});

  final Artist artist;

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
        if (artist.born.isNotEmpty || artist.died.isNotEmpty)
          _FactRow(
            label: 'الحياة',
            value: [
              artist.born,
              artist.died,
            ].where((year) => year.isNotEmpty).join(' – '),
            ltr: true,
          ),
        if (artist.place.isNotEmpty) ...[
          if (artist.born.isNotEmpty || artist.died.isNotEmpty)
            const SizedBox(height: 12),
          _FactRow(label: 'المكان', value: artist.place),
        ],
      ],
    ),
  );
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.label, required this.value, this.ltr = false});

  final String label;
  final String value;
  final bool ltr;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 96,
        child: Text(label, style: const TextStyle(color: WashijColors.mist)),
      ),
      Expanded(
        child: Text(
          value,
          textDirection: ltr ? TextDirection.ltr : null,
          style: const TextStyle(color: WashijColors.ivory),
        ),
      ),
    ],
  );
}

class _NarrativeSection extends StatelessWidget {
  const _NarrativeSection({
    required this.title,
    required this.text,
    required this.emptyMessage,
  });

  final String title;
  final String text;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SectionHeader(title: title),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Text(
          text.isEmpty ? emptyMessage : text,
          style: WashijTypography.textTheme.bodyLarge?.copyWith(
            color: text.isEmpty ? WashijColors.mist : WashijColors.ivory,
          ),
        ),
      ),
    ],
  );
}

class _MovementLinkCard extends StatelessWidget {
  const _MovementLinkCard({required this.movement});

  final Movement movement;

  @override
  Widget build(BuildContext context) => Semantics(
    link: true,
    label: 'المدرسة الفنية ${movement.nameAr}، ${movement.nameOrig}',
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
                context.push('/movement/${Uri.encodeComponent(movement.id)}'),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    movement.nameAr,
                    style: WashijTypography.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movement.period,
                    style: const TextStyle(color: WashijColors.mutedSky),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _ArtistNotFound extends StatelessWidget {
  const _ArtistNotFound();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 80),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'لم نعثر على الفنان المطلوب.',
            textAlign: TextAlign.center,
            style: WashijTypography.textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => context.go('/artists'),
            child: const Text('العودة إلى دليل الفنانين'),
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
