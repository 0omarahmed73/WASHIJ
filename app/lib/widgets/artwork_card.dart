import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/models/artist.dart';
import '../data/models/artwork.dart';
import '../theme/tokens.dart';
import 'mat.dart';
import 'focus_ring.dart';

class ArtworkCard extends StatelessWidget {
  const ArtworkCard({super.key, required this.artwork, required this.artist});

  final Artwork artwork;
  final Artist artist;

  @override
  Widget build(BuildContext context) => Semantics(
    link: true,
    label: '${artwork.titleAr}، ${artwork.titleOrig}، ${artist.nameAr}',
    child: FocusRing(
      child: InkWell(
        onTap: () => context.push('/artwork/${artwork.id}'),
        child: Container(
          decoration: const BoxDecoration(
            color: WashijColors.deepBlue,
            border: Border.fromBorderSide(
              BorderSide(color: WashijColors.hairline),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ArtworkMat(artwork: artwork, aspectRatio: 4 / 3, padding: 8),
              const SizedBox(height: 14),
              Text(
                artwork.titleAr,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                artist.nameAr,
                style: const TextStyle(color: WashijColors.mist),
              ),
              const SizedBox(height: 4),
              Text(
                artwork.dateText,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
