import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog.dart';
import '../data/models/artist.dart';
import '../data/models/artwork.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/mat.dart';
import '../widgets/museum_page.dart';
import '../widgets/page_width.dart';
import '../widgets/section_header.dart';
import '../widgets/focus_ring.dart';

class ArtistsPage extends ConsumerWidget {
  const ArtistsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MuseumPage(
        slivers: [
          catalog.when(
            data: (value) => SliverToBoxAdapter(
              child: PageWidth(child: _ArtistsIndex(catalog: value)),
            ),
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: _CatalogStatus(
                message: 'جارٍ تحميل دليل الفنانين',
                loading: true,
              ),
            ),
            error: (error, stackTrace) => SliverFillRemaining(
              hasScrollBody: false,
              child: _CatalogStatus(
                message: 'تعذّر تحميل دليل الفنانين.',
                onRetry: () => ref.invalidate(catalogProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtistsIndex extends StatelessWidget {
  const _ArtistsIndex({required this.catalog});

  final Catalog catalog;

  @override
  Widget build(BuildContext context) {
    final artists = catalog.artists.values.toList(growable: false);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'الفنانون'),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Text(
              'سير الفنانين وأساليبهم والأعمال التي تركوها.',
              style: WashijTypography.textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 36),
          if (artists.isEmpty)
            const _EmptyState(message: 'لا توجد سير فنانين متاحة الآن.')
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 960
                    ? 3
                    : constraints.maxWidth >= 600
                    ? 2
                    : 1;
                const gap = 20.0;
                final cardWidth =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final artist in artists)
                      SizedBox(
                        width: cardWidth,
                        child: _ArtistCard(
                          artist: artist,
                          leadArtwork: catalog.artwork(artist.leadArtworkId),
                        ),
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

class _ArtistCard extends StatelessWidget {
  const _ArtistCard({required this.artist, required this.leadArtwork});

  final Artist artist;
  final Artwork? leadArtwork;

  @override
  Widget build(BuildContext context) {
    final artwork = leadArtwork;
    return Semantics(
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (artwork != null) ...[
                      ArtworkMat(
                        artwork: artwork,
                        aspectRatio: 4 / 3,
                        padding: 8,
                      ),
                      const SizedBox(height: 16),
                    ],
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
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (artist.born.isNotEmpty || artist.died.isNotEmpty)
                      Text(
                        [
                          artist.born,
                          artist.died,
                        ].where((year) => year.isNotEmpty).join(' – '),
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(color: WashijColors.mutedSky),
                      ),
                    if (artist.bio.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        artist.bio,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: WashijTypography.textTheme.bodyMedium,
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
    padding: const EdgeInsets.all(24),
    decoration: const BoxDecoration(
      color: WashijColors.deepBlue,
      border: Border.fromBorderSide(BorderSide(color: WashijColors.hairline)),
    ),
    child: Text(message, style: const TextStyle(color: WashijColors.mist)),
  );
}
