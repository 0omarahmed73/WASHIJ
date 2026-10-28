import 'package:flutter/material.dart';

import '../data/models/artwork.dart';
import '../theme/tokens.dart';

class CropDetail extends StatelessWidget {
  const CropDetail({super.key, required this.artwork, required this.detail});

  final Artwork artwork;
  final ArtworkDetail detail;

  @override
  Widget build(BuildContext context) {
    final image = artwork.image;
    final crop = detail.crop;
    if (image == null || crop == null) return const SizedBox.shrink();

    final cropRatio = image.width * crop.width / (image.height * crop.height);
    return Container(
      decoration: const BoxDecoration(
        color: WashijColors.deepBlue,
        border: Border.fromBorderSide(BorderSide(color: WashijColors.hairline)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRect(
            child: AspectRatio(
              aspectRatio: cropRatio,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final sourceWidth = constraints.maxWidth * 100 / crop.width;
                  final sourceHeight =
                      constraints.maxHeight * 100 / crop.height;
                  return Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Positioned(
                        left: -constraints.maxWidth * crop.x / crop.width,
                        top: -constraints.maxHeight * crop.y / crop.height,
                        width: sourceWidth,
                        height: sourceHeight,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(image.asset, fit: BoxFit.fill),
                            if (image.remoteUrl case final url?)
                              Image.network(
                                url,
                                fit: BoxFit.fill,
                                frameBuilder:
                                    (context, child, frame, syncLoaded) =>
                                        frame != null || syncLoaded
                                        ? child
                                        : const SizedBox.shrink(),
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox.shrink(),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(detail.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            detail.text,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: WashijColors.mist),
          ),
          const SizedBox(height: 8),
          const Text(
            'تفصيل مقصوص من اللوحة الأصلية',
            style: TextStyle(color: WashijColors.mutedSky, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
