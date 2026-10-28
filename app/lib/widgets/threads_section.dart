import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog.dart';
import '../theme/tokens.dart';
import 'page_width.dart';
import 'section_header.dart';
import 'thread_separator.dart';
import 'focus_ring.dart';

class ThreadsSection extends StatelessWidget {
  const ThreadsSection({super.key, required this.catalog});

  final Catalog catalog;

  @override
  Widget build(BuildContext context) {
    final source = catalog.artwork('starry-night');
    if (source == null) return const SizedBox.shrink();
    final links = source.related
        .map((related) => (related, catalog.artwork(related.artworkId)))
        .where((entry) => entry.$2 != null)
        .toList(growable: false);
    return PageWidth(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(title: 'خيوط تصل بين اللوحات'),
            for (final (related, artwork) in links)
              if (artwork case final work?) ...[
                FocusRing(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(work.titleAr),
                    subtitle: Text(
                      related.reason,
                      style: const TextStyle(color: WashijColors.mist),
                    ),
                    trailing: const Icon(
                      Icons.arrow_back,
                      color: WashijColors.mutedSky,
                    ),
                    onTap: () => context.push('/artwork/${work.id}'),
                  ),
                ),
                const ThreadSeparator(height: 18),
              ],
          ],
        ),
      ),
    );
  }
}
