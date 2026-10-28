import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/models/cleveland_artwork.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'focus_ring.dart';
import 'painting_image_loading.dart';

class ClevelandArtworkCard extends StatelessWidget {
  const ClevelandArtworkCard({super.key, required this.artwork});

  final ClevelandArtwork artwork;

  @override
  Widget build(BuildContext context) {
    final arabicTitle = artwork.titleArabic?.trim();
    final title = arabicTitle == null || arabicTitle.isEmpty
        ? artwork.title
        : arabicTitle;

    return Semantics(
      link: true,
      label: '$title، ${artwork.artistDisplay}',
      child: Material(
        color: WashijColors.deepBlue,
        child: FocusRing(
          child: InkWell(
            onTap: () => context.push('/artwork/cleveland/${artwork.id}'),
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
                        child: Image.network(
                          artwork.imageUrl,
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
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: WashijTypography.textTheme.titleLarge,
                  ),
                  if (title != artwork.title) ...[
                    const SizedBox(height: 3),
                    Text(
                      artwork.title,
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
                  ],
                  const SizedBox(height: 8),
                  Text(
                    artwork.artistDisplay,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: WashijColors.mist),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    artwork.dateDisplay,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'من متحف كليفلاند للفنون · CC0',
                    style: TextStyle(
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
}
