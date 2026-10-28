import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/catalog.dart';
import '../state/hero_state.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../widgets/discovery_rail.dart';
import '../widgets/entry_tiles.dart';
import '../widgets/featured_artists.dart';
import '../widgets/frames_strip.dart';
import '../widgets/hero.dart';
import '../widgets/hourly_painting.dart';
import '../widgets/manifesto_band.dart';
import '../widgets/movements_list.dart';
import '../widgets/museum_page.dart';
import '../widgets/page_width.dart';
import '../widgets/section_header.dart';
import '../widgets/spotlight.dart';
import '../widgets/threads_section.dart';
import '../widgets/artwork_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    return catalog.when(
      data: (value) => RefreshIndicator(
        color: WashijColors.midnight,
        backgroundColor: WashijColors.starYellow,
        semanticsLabel: 'تحديث اللوحات المعروضة',
        onRefresh: () async =>
            ref.read(heroPagerProvider.notifier).refresh(value.artworks),
        child: MuseumPage(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: HomeHero(catalog: value)),
            const SliverToBoxAdapter(child: ManifestoBand()),
            SliverToBoxAdapter(child: FramesStrip(catalog: value)),
            SliverToBoxAdapter(child: _CuratedCollection(catalog: value)),
            const SliverToBoxAdapter(child: HourlyPainting()),
            SliverToBoxAdapter(child: Spotlight(catalog: value)),
            SliverToBoxAdapter(child: DiscoveryRail(catalog: value)),
            SliverToBoxAdapter(child: FeaturedArtists(catalog: value)),
            SliverToBoxAdapter(child: MovementsList(catalog: value)),
            SliverToBoxAdapter(child: ThreadsSection(catalog: value)),
            const SliverToBoxAdapter(child: EntryTiles()),
          ],
        ),
      ),
      loading: () => MuseumPage(
        slivers: const [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: CircularProgressIndicator(color: WashijColors.starYellow),
            ),
          ),
        ],
      ),
      error: (error, stackTrace) => MuseumPage(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: WashijColors.danger),
                  const SizedBox(height: 12),
                  const Text('تعذّر تحميل المجموعة.'),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => ref.invalidate(catalogProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CuratedCollection extends StatelessWidget {
  const _CuratedCollection({required this.catalog});

  final Catalog catalog;

  @override
  Widget build(BuildContext context) => PageWidth(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'مختارات من المجموعة'),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1050
                  ? 3
                  : constraints.maxWidth >= 600
                  ? 2
                  : 1;
              const gap = 20.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              final works = catalog.artworks.take(6).toList(growable: false);
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
    ),
  );
}
