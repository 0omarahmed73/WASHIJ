import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog.dart';
import '../data/models/artist.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'page_width.dart';
import 'section_header.dart';
import 'focus_ring.dart';

class FeaturedArtists extends StatelessWidget {
  const FeaturedArtists({super.key, required this.catalog});

  final Catalog catalog;

  @override
  Widget build(BuildContext context) {
    final ids = ['van-gogh', 'hokusai', 'vermeer', 'da-vinci'];
    final artists = ids
        .map((id) => catalog.artists[id])
        .whereType<Artist>()
        .toList(growable: false);
    return PageWidth(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: 'فنانون',
              action: TextButton(
                onPressed: () => context.push('/artists'),
                child: const Text('دليل الفنانين'),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900
                    ? 4
                    : constraints.maxWidth >= 600
                    ? 2
                    : 1;
                const gap = 16.0;
                final width =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final artist in artists)
                      SizedBox(
                        width: width,
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
                                    context.push('/artist/${artist.id}'),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        artist.nameAr,
                                        style: WashijTypography
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        artist.nameOrig,
                                        textDirection: TextDirection.ltr,
                                        style: const TextStyle(
                                          color: WashijColors.mist,
                                        ),
                                      ),
                                      if (artist.style.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Text(
                                          artist.style,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: WashijColors.mist,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
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
}
