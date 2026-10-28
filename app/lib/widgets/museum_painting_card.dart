import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/models/museum_painting.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'focus_ring.dart';
import 'painting_image_loading.dart';

class MuseumPaintingCard extends StatelessWidget {
  const MuseumPaintingCard({super.key, required this.painting});

  final MuseumPainting painting;

  @override
  Widget build(BuildContext context) => Semantics(
    link: true,
    label: '${painting.titleArabic}، ${painting.artistArabic}',
    child: Material(
      color: WashijColors.deepBlue,
      child: FocusRing(
        child: InkWell(
          onTap: () => context.push('/artwork/museum/${painting.id}'),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border.fromBorderSide(
                BorderSide(color: WashijColors.hairline),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 210,
                  child: ColoredBox(
                    color: WashijColors.nightRaised,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: painting.imageAsset != null
                          ? Image.asset(
                              painting.imageAsset!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: WashijColors.mist,
                                    ),
                                  ),
                            )
                          : painting.imageUrl == null
                          ? const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: WashijColors.mist,
                              ),
                            )
                          : Image.network(
                              painting.imageUrl!,
                              fit: BoxFit.contain,
                              loadingBuilder: paintingImageLoadingBuilder,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: WashijColors.mist,
                                    ),
                                  ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  painting.titleArabic,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: WashijTypography.textTheme.titleLarge,
                ),
                const SizedBox(height: 3),
                Text(
                  painting.title,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: WashijTypography.englishDisplay.copyWith(
                    fontSize: 17,
                    letterSpacing: 0,
                    color: WashijColors.mist,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  painting.artistArabic,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: WashijColors.mist),
                ),
                const SizedBox(height: 10),
                Text(
                  painting.sourceNameArabic,
                  style: const TextStyle(
                    color: WashijColors.mutedSky,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
