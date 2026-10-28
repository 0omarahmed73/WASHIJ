import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog.dart';
import '../data/models/artwork.dart';
import '../theme/tokens.dart';
import 'mat.dart';
import 'page_width.dart';
import 'section_header.dart';

class Spotlight extends StatelessWidget {
  const Spotlight({super.key, required this.catalog});

  final Catalog catalog;

  @override
  Widget build(BuildContext context) {
    final artwork = catalog.artwork('great-wave');
    if (artwork == null) return const SizedBox.shrink();
    return PageWidth(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(title: 'في ضوء التاريخ'),
            LayoutBuilder(
              builder: (context, constraints) {
                final painting = ArtworkMat(
                  artwork: artwork,
                  aspectRatio: artwork.image == null
                      ? 4 / 3
                      : artwork.image!.width / artwork.image!.height,
                  padding: 16,
                );
                final story = _SpotlightCopy(artwork: artwork);
                if (constraints.maxWidth < 800) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [painting, const SizedBox(height: 24), story],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: painting),
                    const SizedBox(width: 40),
                    Expanded(child: story),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SpotlightCopy extends StatelessWidget {
  const _SpotlightCopy({required this.artwork});

  final Artwork artwork;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(artwork.titleAr, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      Text(
        artwork.titleOrig,
        textDirection: TextDirection.ltr,
        style: const TextStyle(color: WashijColors.mist),
      ),
      const SizedBox(height: 20),
      Text(artwork.intro, style: Theme.of(context).textTheme.bodyLarge),
      if (artwork.story.isNotEmpty) ...[
        const SizedBox(height: 16),
        Text(
          artwork.story.first,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: WashijColors.mist),
        ),
      ],
      const SizedBox(height: 18),
      TextButton.icon(
        onPressed: () => context.push('/artwork/${artwork.id}'),
        icon: const Icon(Icons.arrow_back),
        label: const Text('اقرأ حكاية اللوحة'),
      ),
    ],
  );
}
