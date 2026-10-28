import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/museum_painting.dart';
import '../state/hourly_painting_state.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'page_width.dart';
import 'section_header.dart';
import 'focus_ring.dart';
import 'painting_image_loading.dart';

/// Home-page section showing one painting that changes every hour, with a
/// button to see another. Tapping the painting opens its page in the app.
class HourlyPainting extends ConsumerWidget {
  const HourlyPainting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paintings = ref.watch(museumPaintingsProvider);
    final state = ref.watch(hourlyPaintingControllerProvider);
    final painting = paintings.asData == null
        ? null
        : pickHourlyPainting(paintings.asData!.value, state);
    if (paintings.hasError || (paintings.hasValue && painting == null)) {
      return const SizedBox.shrink();
    }
    return PageWidth(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: 'لوحة هذه الساعة',
              action: OutlinedButton.icon(
                onPressed: painting == null
                    ? null
                    : ref
                          .read(hourlyPaintingControllerProvider.notifier)
                          .refresh,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('لوحة أخرى'),
              ),
            ),
            if (painting == null)
              const SizedBox(
                height: 260,
                child: ColoredBox(
                  color: WashijColors.deepBlue,
                  child: Center(
                    child: Text(
                      'جارٍ تحميل اللوحة…',
                      style: TextStyle(color: WashijColors.mist),
                    ),
                  ),
                ),
              )
            else
              _HourlyPaintingCard(painting: painting),
          ],
        ),
      ),
    );
  }
}

class _HourlyPaintingCard extends StatelessWidget {
  const _HourlyPaintingCard({required this.painting});

  final MuseumPainting painting;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      link: true,
      label:
          'لوحة هذه الساعة: ${painting.titleArabic}، ${painting.artistArabic}',
      child: Material(
        color: WashijColors.deepBlue,
        child: FocusRing(
          child: InkWell(
            onTap: () => context.push('/artwork/museum/${painting.id}'),
            child: Container(
              decoration: const BoxDecoration(
                border: Border.fromBorderSide(
                  BorderSide(color: WashijColors.hairline),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 720;
                  final image = _Image(painting: painting);
                  final text = _Caption(painting: painting);
                  return AnimatedSwitcher(
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 250),
                    child: KeyedSubtree(
                      key: ValueKey(painting.id),
                      child: wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(flex: 5, child: image),
                                const SizedBox(width: 32),
                                Expanded(flex: 4, child: text),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                image,
                                const SizedBox(height: 20),
                                text,
                              ],
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Image extends StatelessWidget {
  const _Image({required this.painting});

  final MuseumPainting painting;

  @override
  Widget build(BuildContext context) {
    final image = painting.imageAsset != null
        ? Image.asset(
            painting.imageAsset!,
            fit: BoxFit.contain,
            semanticLabel: painting.titleArabic,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: WashijColors.mist,
              ),
            ),
          )
        : Image.network(
            painting.imageUrl!,
            fit: BoxFit.contain,
            semanticLabel: painting.titleArabic,
            loadingBuilder: paintingImageLoadingBuilder,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: WashijColors.mist,
              ),
            ),
          );
    return SizedBox(
      height: 320,
      child: ColoredBox(
        color: WashijColors.nightRaised,
        child: Padding(
          padding: const EdgeInsets.all(10),
          // The whole painting, uncropped and unfiltered.
          child: image,
        ),
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption({required this.painting});

  final MuseumPainting painting;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        painting.titleArabic,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: WashijTypography.textTheme.headlineSmall,
      ),
      const SizedBox(height: 4),
      Text(
        painting.title,
        textDirection: TextDirection.ltr,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: WashijTypography.englishDisplay.copyWith(
          fontSize: 18,
          letterSpacing: 0,
          color: WashijColors.mist,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        painting.artistArabic,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: WashijColors.mist),
      ),
      const SizedBox(height: 6),
      Text(
        painting.sourceNameArabic,
        style: const TextStyle(color: WashijColors.mutedSky, fontSize: 12),
      ),
      const SizedBox(height: 16),
      const Text('افتح اللوحة', style: TextStyle(color: WashijColors.mutedSky)),
    ],
  );
}
