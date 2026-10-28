import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'page_width.dart';
import 'section_header.dart';
import 'focus_ring.dart';

class MovementsList extends StatelessWidget {
  const MovementsList({super.key, required this.catalog});

  final Catalog catalog;

  @override
  Widget build(BuildContext context) => PageWidth(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: 'مدارس فنية',
            action: TextButton(
              onPressed: () => context.push('/movements'),
              child: const Text('كل المدارس'),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1000
                  ? 3
                  : constraints.maxWidth >= 620
                  ? 2
                  : 1;
              const gap = 16.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final movement in catalog.movements.values)
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
                                  context.push('/movement/${movement.id}'),
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movement.nameAr,
                                      style:
                                          WashijTypography.textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      movement.nameOrig,
                                      textDirection: TextDirection.ltr,
                                      style: const TextStyle(
                                        color: WashijColors.mist,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      movement.period,
                                      style: const TextStyle(
                                        color: WashijColors.mutedSky,
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
