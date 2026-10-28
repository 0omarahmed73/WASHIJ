import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'page_width.dart';
import 'section_header.dart';
import 'focus_ring.dart';

class EntryTiles extends StatelessWidget {
  const EntryTiles({super.key});

  static const _entries = [
    ('اللوحات', 'ابدأ من العمل الفني', '/artworks', Icons.image_outlined),
    ('الفنانون', 'اقترب من حكاياتهم', '/artists', Icons.person_outline),
    (
      'المدارس الفنية',
      'اكتشف الأفكار التي وصلت بينهم',
      '/movements',
      Icons.account_tree_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) => PageWidth(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'من أين تبدأ؟'),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 680 ? 1 : 3;
              const gap = 16.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final (title, body, path, icon) in _entries)
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
                              onTap: () => context.push(path),
                              child: Padding(
                                padding: const EdgeInsets.all(22),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(icon, color: WashijColors.mutedSky),
                                    const SizedBox(height: 16),
                                    Text(
                                      title,
                                      style:
                                          WashijTypography.textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      body,
                                      style: const TextStyle(
                                        color: WashijColors.mist,
                                      ),
                                    ),
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
