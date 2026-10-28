import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/catalog.dart';
import '../data/models/artist.dart';
import '../data/models/artwork.dart';
import '../data/models/movement.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/artwork_card.dart';
import '../data/models/shareable_painting.dart';
import '../widgets/artwork_share_card.dart';
import '../widgets/painting_actions.dart';
import '../widgets/crop_detail.dart';
import '../widgets/lightbox.dart';
import '../widgets/mat.dart';
import '../widgets/museum_page.dart';
import '../widgets/page_width.dart';
import '../widgets/section_header.dart';
import '../paint/long_thread.dart';
import '../widgets/focus_ring.dart';

class ArtworkPage extends ConsumerWidget {
  const ArtworkPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    return catalog.when(
      data: (value) {
        final artwork = value.artwork(id);
        final artist = artwork == null ? null : value.artists[artwork.artistId];
        if (artwork == null || artist == null) {
          return MuseumPage(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: _ArtworkNotFound(),
              ),
            ],
          );
        }
        return _ArtworkDetailPage(
          catalog: value,
          artwork: artwork,
          artist: artist,
        );
      },
      loading: () => MuseumPage(
        slivers: const [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: CircularProgressIndicator(color: WashijColors.starYellow),
            ),
          ),
        ],
      ),
      error: (error, stackTrace) => MuseumPage(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: _CatalogError(
              onRetry: () => ref.invalidate(catalogProvider),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtworkDetailPage extends StatefulWidget {
  const _ArtworkDetailPage({
    required this.catalog,
    required this.artwork,
    required this.artist,
  });

  final Catalog catalog;
  final Artwork artwork;
  final Artist artist;

  @override
  State<_ArtworkDetailPage> createState() => _ArtworkDetailPageState();
}

class _ArtworkDetailPageState extends State<_ArtworkDetailPage> {
  final _sectionKeys = {
    'story': GlobalKey(),
    'reading': GlobalKey(),
    'details': GlobalKey(),
    'interpretations': GlobalKey(),
    'sources': GlobalKey(),
    'related': GlobalKey(),
  };

  @override
  Widget build(BuildContext context) => MuseumPage(
    slivers: [
      SliverToBoxAdapter(child: _hero(context)),
      SliverPersistentHeader(
        pinned: true,
        delegate: _DetailNavDelegate(
          onSelect: (id) => _scrollTo(_sectionKeys[id]!),
        ),
      ),
      SliverToBoxAdapter(child: _body(context)),
    ],
  );

  Widget _hero(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Stack(
      clipBehavior: Clip.none,
      children: [
        PageWidth(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(top: 40, bottom: 32),
            child: LayoutBuilder(
              builder: (context, inner) {
                final painting = _painting(context);
                final information = _information(context);
                if (inner.maxWidth < 920) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      painting,
                      const SizedBox(height: 32),
                      information,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: painting),
                    const SizedBox(width: 48),
                    Expanded(flex: 5, child: information),
                  ],
                );
              },
            ),
          ),
        ),
        if (constraints.maxWidth >= 1500)
          PositionedDirectional(
            end: 30,
            top: 80,
            child: RotatedBox(
              quarterTurns: 1,
              child: LongThread(width: 460, height: 40),
            ),
          ),
      ],
    ),
  );

  Widget _painting(BuildContext context) {
    final image = widget.artwork.image;
    final mat = ArtworkMat(
      artwork: widget.artwork,
      aspectRatio: image == null ? 4 / 3 : image.width / image.height,
      cornerMarks: true,
      padding: 20,
    );
    if (image == null) return mat;
    return Semantics(
      button: true,
      label: 'تكبير ${widget.artwork.titleAr}',
      child: FocusRing(
        child: InkWell(
          onTap: () => showArtworkLightbox(context, widget.artwork),
          child: mat,
        ),
      ),
    );
  }

  Widget _information(BuildContext context) {
    final artwork = widget.artwork;
    final artist = widget.artist;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(artwork.titleAr, style: WashijTypography.textTheme.displayMedium),
        const SizedBox(height: 8),
        Text(
          artwork.titleOrig,
          textDirection: TextDirection.ltr,
          style: WashijTypography.englishDisplay.copyWith(
            color: WashijColors.mist,
            fontSize: 24,
            letterSpacing: 7.68,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          artwork.poem,
          style: WashijTypography.textTheme.bodyLarge?.copyWith(
            color: WashijColors.ivory,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'بيت تحريري من وَشيج',
          style: TextStyle(color: WashijColors.mutedSky, fontSize: 13),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => context.push('/artist/${artist.id}'),
          icon: const Icon(Icons.person_outline),
          label: Text(artist.nameAr),
        ),
        const SizedBox(height: 12),
        if (artwork.image == null)
          ArtworkShareCard(artwork: artwork, artist: artist)
        else
          PaintingActions(
            painting: ShareablePainting.fromArtwork(artwork, artist),
            showZoom: false,
          ),
        if (artwork.image != null) ...[
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => showArtworkLightbox(context, artwork),
            style: FilledButton.styleFrom(
              backgroundColor: WashijColors.starYellow,
              foregroundColor: WashijColors.midnight,
              minimumSize: const Size(44, 48),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            icon: const Icon(Icons.zoom_in),
            label: const Text('تكبير اللوحة'),
          ),
        ],
        const SizedBox(height: 28),
        _Facts(
          artwork: artwork,
          movement: widget.catalog.movements[artwork.movementId],
        ),
      ],
    );
  }

  Widget _body(BuildContext context) => PageWidth(
    child: Padding(
      padding: const EdgeInsetsDirectional.only(top: 8, bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _section(
            id: 'story',
            title: 'حكاية اللوحة',
            child: _paragraphs(widget.artwork.story),
          ),
          _section(
            id: 'reading',
            title: 'قراءة فنية',
            child: _paragraphs(widget.artwork.reading),
          ),
          _section(
            id: 'details',
            title: 'تفاصيل تستحق الانتباه',
            child: _details(context),
          ),
          _section(
            id: 'interpretations',
            title: 'تفسيرات منسوبة',
            child: _interpretations(context),
          ),
          _section(
            id: 'sources',
            title: 'المصادر والاعتمادات',
            child: _sources(context),
          ),
          _section(
            id: 'related',
            title: 'لوحات متصلة',
            child: _related(context),
          ),
        ],
      ),
    ),
  );

  Widget _section({
    required String id,
    required String title,
    required Widget child,
  }) => Padding(
    key: _sectionKeys[id],
    padding: const EdgeInsetsDirectional.only(top: 28, bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: title),
        child,
      ],
    ),
  );

  Widget _paragraphs(List<String> paragraphs) {
    if (paragraphs.isEmpty) {
      return const Text(
        'لا تتوفر مادة تحريرية لهذا القسم حتى الآن.',
        style: TextStyle(color: WashijColors.mist),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < paragraphs.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Text(
              paragraphs[i],
              style: WashijTypography.textTheme.bodyLarge,
            ),
          ),
        ],
      ],
    );
  }

  Widget _details(BuildContext context) {
    final details = widget.artwork.details;
    if (details.isEmpty) {
      return const Text(
        'لا توجد تفاصيل إضافية مسجلة لهذه اللوحة.',
        style: TextStyle(color: WashijColors.mist),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000
            ? 3
            : constraints.maxWidth >= 620
            ? 2
            : 1;
        const gap = 20.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final detail in details)
              SizedBox(
                width: width,
                child: detail.crop == null
                    ? _DetailCard(detail: detail)
                    : CropDetail(artwork: widget.artwork, detail: detail),
              ),
          ],
        );
      },
    );
  }

  Widget _interpretations(BuildContext context) {
    final items = widget.artwork.interpretations;
    if (items.isEmpty) {
      return const Text(
        'لا توجد تفسيرات موثقة لهذا العمل في هذا السجل.',
        style: TextStyle(color: WashijColors.mist),
      );
    }
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        for (final item in items)
          SizedBox(
            width: math.min(560, MediaQuery.sizeOf(context).width - 80),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: WashijColors.deepBlue,
                border: Border.fromBorderSide(
                  BorderSide(color: WashijColors.hairline),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(item.text, style: WashijTypography.textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  Text(
                    'النسبة: ${item.attribution}',
                    style: const TextStyle(color: WashijColors.mutedSky),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _sources(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _CreditLine(artwork: widget.artwork),
      if (widget.artwork.sources.isNotEmpty) ...[
        const SizedBox(height: 20),
        for (final source in widget.artwork.sources)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => _openExternal(context, source.url),
              icon: const Icon(Icons.open_in_new),
              label: Text(source.title),
            ),
          ),
      ],
    ],
  );

  Widget _related(BuildContext context) {
    final works = widget.artwork.related
        .map((item) => (item, widget.catalog.artwork(item.artworkId)))
        .where((entry) => entry.$2 != null)
        .toList(growable: false);
    if (works.isEmpty) {
      return const Text(
        'لا توجد لوحات متصلة مسجلة لهذا العمل.',
        style: TextStyle(color: WashijColors.mist),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000
            ? 3
            : constraints.maxWidth >= 620
            ? 2
            : 1;
        const gap = 20.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final (related, maybeArtwork) in works)
              if (maybeArtwork case final artwork?)
                SizedBox(
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.catalog.artists[artwork.artistId]
                          case final artist?)
                        ArtworkCard(artwork: artwork, artist: artist),
                      const SizedBox(height: 10),
                      Text(
                        'صلة: ${related.reason}',
                        style: const TextStyle(color: WashijColors.mist),
                      ),
                    ],
                  ),
                ),
          ],
        );
      },
    );
  }

  void _scrollTo(GlobalKey key) {
    final target = key.currentContext;
    if (target == null) return;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 260);
    Scrollable.ensureVisible(
      target,
      duration: duration,
      curve: Curves.easeOut,
      alignment: 0.08,
    );
  }
}

class _Facts extends StatelessWidget {
  const _Facts({required this.artwork, required this.movement});

  final Artwork artwork;
  final Movement? movement;

  @override
  Widget build(BuildContext context) {
    final facts = [
      ('التاريخ', artwork.dateText),
      ('الخامة', artwork.medium),
      ('الأبعاد', artwork.dimensions),
      ('المكان', artwork.place),
      ('المجموعة', artwork.collection),
      if (movement != null) ('المدرسة الفنية', movement!.nameAr),
    ].where((fact) => fact.$2.trim().isNotEmpty).toList(growable: false);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: WashijColors.deepBlue,
        border: Border.fromBorderSide(BorderSide(color: WashijColors.hairline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < facts.length; i++) ...[
            if (i > 0) const Divider(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 92,
                  child: Text(
                    facts[i].$1,
                    style: const TextStyle(color: WashijColors.mist),
                  ),
                ),
                Expanded(child: Text(facts[i].$2)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.detail});

  final ArtworkDetail detail;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: WashijColors.deepBlue,
      border: Border.fromBorderSide(BorderSide(color: WashijColors.hairline)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(detail.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          detail.text,
          style: WashijTypography.textTheme.bodyMedium?.copyWith(
            color: WashijColors.mist,
          ),
        ),
      ],
    ),
  );
}

class _CreditLine extends StatelessWidget {
  const _CreditLine({required this.artwork});

  final Artwork artwork;

  @override
  Widget build(BuildContext context) {
    final credit = artwork.credit;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: WashijColors.deepBlue,
        border: Border.fromBorderSide(BorderSide(color: WashijColors.hairline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            artwork.image == null
                ? 'الصورة غير معروضة؛ الحقوق محفوظة.'
                : 'اعتماد الصورة: ${credit.author} · ${credit.licence}',
            style: const TextStyle(color: WashijColors.ivory),
          ),
          const SizedBox(height: 8),
          Text(
            credit.attribution,
            textDirection: TextDirection.ltr,
            style: const TextStyle(color: WashijColors.mist, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (credit.fileUrl.isNotEmpty)
                _ExternalLink(
                  label: 'ملف الصورة في ويكيميديا كومنز',
                  url: credit.fileUrl,
                ),
              if (credit.articleUrl.isNotEmpty)
                _ExternalLink(
                  label: 'مقال ويكيبيديا عن اللوحة',
                  url: credit.articleUrl,
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'مقال ويكيبيديا مرخّص وفق CC BY-SA؛ تُنسب المادة إلى أصحابها.',
            style: TextStyle(color: WashijColors.mist, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ExternalLink extends StatelessWidget {
  const _ExternalLink({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: () => _openExternal(context, url),
    icon: const Icon(Icons.open_in_new),
    label: Text(label),
  );
}

Future<void> _openExternal(BuildContext context, String rawUrl) async {
  final uri = Uri.tryParse(rawUrl);
  if (uri == null || uri.scheme != 'https') {
    _showLinkError(context);
    return;
  }
  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) _showLinkError(context);
  } on Object {
    if (context.mounted) _showLinkError(context);
  }
}

void _showLinkError(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('تعذّر فتح رابط المصدر'),
      backgroundColor: WashijColors.danger,
    ),
  );
}

class _ArtworkNotFound extends StatelessWidget {
  const _ArtworkNotFound();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'لم نعثر على هذه اللوحة',
            style: WashijTypography.textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => context.go('/artworks'),
            style: FilledButton.styleFrom(
              backgroundColor: WashijColors.starYellow,
              foregroundColor: WashijColors.midnight,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: const Text('استكشف اللوحات'),
          ),
        ],
      ),
    ),
  );
}

class _CatalogError extends StatelessWidget {
  const _CatalogError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, color: WashijColors.danger),
        const SizedBox(height: 12),
        const Text('تعذّر تحميل بيانات اللوحة.'),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('إعادة المحاولة'),
        ),
      ],
    ),
  );
}

class _DetailNavDelegate extends SliverPersistentHeaderDelegate {
  const _DetailNavDelegate({required this.onSelect});

  final ValueChanged<String> onSelect;

  static const _items = [
    ('story', 'حكاية اللوحة'),
    ('reading', 'قراءة فنية'),
    ('details', 'تفاصيل'),
    ('interpretations', 'تفسيرات'),
    ('sources', 'المصادر'),
    ('related', 'لوحات متصلة'),
  ];

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => Container(
    decoration: const BoxDecoration(
      color: WashijColors.deepBlue,
      border: Border(
        top: BorderSide(color: WashijColors.hairline),
        bottom: BorderSide(color: WashijColors.hairline),
      ),
    ),
    child: PageWidth(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final (id, label) in _items)
              TextButton(onPressed: () => onSelect(id), child: Text(label)),
          ],
        ),
      ),
    ),
  );

  @override
  bool shouldRebuild(covariant _DetailNavDelegate oldDelegate) =>
      oldDelegate.onSelect != onSelect;
}
