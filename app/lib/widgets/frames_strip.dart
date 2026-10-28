import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog.dart';
import '../theme/tokens.dart';
import 'mat.dart';
import 'page_width.dart';
import 'thread_separator.dart';
import 'focus_ring.dart';

class FramesStrip extends StatelessWidget {
  const FramesStrip({super.key, required this.catalog});

  final Catalog catalog;

  @override
  Widget build(BuildContext context) {
    final ids = ['starry-night', 'great-wave', 'night-watch', 'mona-lisa'];
    return PageWidth(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'إطارات على خيط واحد',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/artworks'),
                  child: const Text('كل اللوحات'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < ids.length; index++)
                    if (catalog.artwork(ids[index]) case final work?)
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          end: index == ids.length - 1 ? 0 : 16,
                        ),
                        child: SizedBox(
                          width: 210,
                          child: FocusRing(
                            child: InkWell(
                              onTap: () => context.push('/artwork/${work.id}'),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  DecoratedBox(
                                    decoration: const BoxDecoration(
                                      color: WashijColors.deepBlue,
                                      border: Border.fromBorderSide(
                                        BorderSide(
                                          color: WashijColors.hairline,
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: ArtworkMat(
                                        artwork: work,
                                        aspectRatio: 4 / 3,
                                        padding: 8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    work.titleAr,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: WashijColors.ivory,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const ThreadSeparator(height: 30),
          ],
        ),
      ),
    );
  }
}
