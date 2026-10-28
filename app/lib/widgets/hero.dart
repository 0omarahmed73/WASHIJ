import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog.dart';
import '../data/models/artwork.dart';
import '../state/hero_state.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../paint/long_thread.dart';
import 'page_width.dart';
import 'focus_ring.dart';

class HomeHero extends ConsumerWidget {
  const HomeHero({super.key, required this.catalog});

  final Catalog catalog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pager = ref.watch(heroPagerProvider);
    if (pager.artworkIds.isEmpty) return const SizedBox.shrink();
    final artwork = catalog.artwork(pager.artworkIds[pager.index]);
    if (artwork == null) return const SizedBox.shrink();

    return Column(
      children: [
        PageWidth(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(top: 40, bottom: 28),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final copy = _HeroCopy(
                  index: pager.index,
                  artwork: artwork,
                  artworkCount: pager.artworkIds.length,
                  onRefresh: () => ref
                      .read(heroPagerProvider.notifier)
                      .refresh(catalog.artworks),
                );
                final crop = _HeroCrop(artwork: artwork);
                if (constraints.maxWidth < 900) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [copy, const SizedBox(height: 28), crop],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 5, child: copy),
                    const SizedBox(width: 48),
                    Expanded(flex: 7, child: crop),
                  ],
                );
              },
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsetsDirectional.only(bottom: 28),
          child: LongThread(width: 260, height: 28),
        ),
      ],
    );
  }
}

class _HeroCopy extends ConsumerWidget {
  const _HeroCopy({
    required this.index,
    required this.artwork,
    required this.artworkCount,
    required this.onRefresh,
  });

  final int index;
  final Artwork artwork;
  final int artworkCount;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'متحف رقمي للفن',
        style: TextStyle(color: WashijColors.mutedSky),
      ),
      const SizedBox(height: 16),
      Text(
        'كل لوحة خيط\nفي حكاية الفن',
        style: WashijTypography.textTheme.displayLarge?.copyWith(height: 1.25),
      ),
      const SizedBox(height: 20),
      Text(
        artwork.poem,
        style: WashijTypography.textTheme.bodyLarge?.copyWith(
          color: WashijColors.mist,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'بيت تحريري من وَشيج',
        style: TextStyle(color: WashijColors.mutedSky, fontSize: 12),
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: () => context.push('/artworks'),
        style: FilledButton.styleFrom(
          backgroundColor: WashijColors.starYellow,
          foregroundColor: WashijColors.midnight,
          minimumSize: const Size(44, 50),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: const Text('استكشف اللوحات'),
      ),
      const SizedBox(height: 24),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (var i = 0; i < artworkCount; i++)
            OutlinedButton(
              onPressed: () => ref.read(heroPagerProvider.notifier).select(i),
              style:
                  OutlinedButton.styleFrom(
                    foregroundColor: i == index
                        ? WashijColors.starYellow
                        : WashijColors.ivory,
                    side: BorderSide(
                      color: i == index
                          ? WashijColors.starYellow
                          : WashijColors.borderControl,
                    ),
                    minimumSize: const Size(48, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ).copyWith(
                    side: washijFocusSide(
                      BorderSide(
                        color: i == index
                            ? WashijColors.starYellow
                            : WashijColors.borderControl,
                      ),
                    ),
                  ),
              child: Text('${i + 1}'.padLeft(2, '0')),
            ),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('لوحات أخرى'),
            style:
                OutlinedButton.styleFrom(
                  foregroundColor: WashijColors.ivory,
                  side: const BorderSide(color: WashijColors.borderControl),
                  minimumSize: const Size(48, 44),
                ).copyWith(
                  side: washijFocusSide(
                    const BorderSide(color: WashijColors.borderControl),
                  ),
                ),
          ),
          Text(
            artwork.titleAr,
            style: const TextStyle(color: WashijColors.mist),
          ),
        ],
      ),
    ],
  );
}

class _HeroCrop extends StatelessWidget {
  const _HeroCrop({required this.artwork});

  final Artwork artwork;

  @override
  Widget build(BuildContext context) {
    final image = artwork.image;
    if (image == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          label: 'قصاصة من ${artwork.titleAr}، افتح اللوحة كاملة',
          child: FocusRing(
            child: InkWell(
              onTap: () => context.push('/artwork/${artwork.id}'),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: WashijColors.nightRaised,
                    border: Border.fromBorderSide(
                      BorderSide(color: WashijColors.hairline),
                    ),
                  ),
                  child: ClipRect(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          image.asset,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                        if (image.remoteUrl case final url?)
                          Image.network(
                            url,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            frameBuilder:
                                (
                                  context,
                                  child,
                                  frame,
                                  wasSynchronouslyLoaded,
                                ) => frame != null || wasSynchronouslyLoaded
                                ? child
                                : const SizedBox.shrink(),
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox.shrink(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            const Padding(
              padding: EdgeInsetsDirectional.only(start: 12),
              child: Text(
                'قصاصة من اللوحة',
                style: TextStyle(color: WashijColors.mist, fontSize: 13),
              ),
            ),
            TextButton.icon(
              onPressed: () => context.push('/artwork/${artwork.id}'),
              icon: const Icon(Icons.open_in_new),
              label: const Text('العمل كاملًا'),
            ),
          ],
        ),
      ],
    );
  }
}
