import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../theme/tokens.dart';
import 'artwork_card.dart';
import 'page_width.dart';
import 'section_header.dart';

class DiscoveryRail extends StatelessWidget {
  const DiscoveryRail({super.key, required this.catalog});

  final Catalog catalog;

  @override
  Widget build(BuildContext context) {
    final works = catalog.artworks.take(8).toList(growable: false);
    return PageWidth(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(title: 'أعمال تستحق الاكتشاف'),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < works.length; index++)
                    if (catalog.artists[works[index].artistId]
                        case final artist?)
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          end: index == works.length - 1 ? 0 : 16,
                        ),
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width < 600
                              ? 230
                              : 270,
                          child: ArtworkCard(
                            artwork: works[index],
                            artist: artist,
                          ),
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'اسحب أفقيًا لقراءة بقية الأعمال.',
              style: TextStyle(color: WashijColors.mist, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
