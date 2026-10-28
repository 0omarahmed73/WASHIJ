import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/arabic_normalise.dart';
import '../data/catalog.dart';
import '../data/models/cleveland_artwork.dart';
import '../data/models/museum_painting.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import 'focus_ring.dart';

class SearchOverlay extends ConsumerStatefulWidget {
  const SearchOverlay({super.key, required this.onSelect});

  final ValueChanged<String> onSelect;

  @override
  ConsumerState<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends ConsumerState<SearchOverlay> {
  static const _onlineSearchDebounce = Duration(milliseconds: 350);

  final _controller = TextEditingController();
  String _query = '';
  Timer? _searchDebounce;
  var _searchRequestId = 0;
  var _onlineLoading = false;
  var _onlineFailed = false;
  List<ClevelandArtwork> _onlineResults = const [];

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchRequestId++;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    final museumPaintings = ref.watch(museumPaintingsProvider);
    return AlertDialog(
      backgroundColor: WashijColors.deepBlue,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: WashijColors.borderControl),
        borderRadius: BorderRadius.zero,
      ),
      title: const Text('ابحث عن لوحة أو فنان'),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'اكتب اسمًا بالعربية أو بالإنجليزية',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _onQueryChanged,
              onSubmitted: _onQueryChanged,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: catalog.when(
                data: (value) => _results(value, museumPaintings),
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: WashijColors.starYellow,
                  ),
                ),
                error: (error, stackTrace) => const Text(
                  'تعذّر تحميل المجموعة للبحث.',
                  style: TextStyle(color: WashijColors.danger),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }

  void _onQueryChanged(String value) {
    final query = value.trim();
    _searchDebounce?.cancel();
    final requestId = ++_searchRequestId;
    setState(() {
      _query = value;
      _onlineResults = const [];
      _onlineFailed = false;
      _onlineLoading = query.length >= 2;
    });

    if (query.length < 2) return;
    _searchDebounce = Timer(_onlineSearchDebounce, () {
      unawaited(_searchOnline(query, requestId));
    });
  }

  Future<void> _searchOnline(String query, int requestId) async {
    try {
      final results = await ref
          .read(clevelandRemoteSourceProvider)
          .searchPaintings(query: query);
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _onlineResults = results;
        _onlineLoading = false;
      });
    } on Object {
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _onlineLoading = false;
        _onlineFailed = true;
      });
    }
  }

  void _retryOnlineSearch() {
    final query = _query.trim();
    if (query.length < 2) return;
    final requestId = ++_searchRequestId;
    setState(() {
      _onlineLoading = true;
      _onlineFailed = false;
    });
    unawaited(_searchOnline(query, requestId));
  }

  Widget _results(
    Catalog catalog,
    AsyncValue<List<MuseumPainting>> museumPaintings,
  ) {
    final query = normaliseSearchText(_query);
    if (query.isEmpty) {
      return const Center(
        child: Text(
          'تظهر النتائج هنا أثناء الكتابة.',
          style: TextStyle(color: WashijColors.mist),
        ),
      );
    }
    final works = catalog.artworks
        .where((work) {
          final artist = catalog.artists[work.artistId];
          return [
            work.titleAr,
            work.titleOrig,
            if (artist != null) artist.nameAr,
            if (artist != null) artist.nameOrig,
          ].map(normaliseSearchText).any((value) => value.contains(query));
        })
        .take(6)
        .toList(growable: false);
    final artists = catalog.artists.values
        .where(
          (artist) => [
            artist.nameAr,
            artist.nameOrig,
          ].map(normaliseSearchText).any((value) => value.contains(query)),
        )
        .take(4)
        .toList(growable: false);
    final translated =
        (museumPaintings.asData?.value ?? const <MuseumPainting>[])
            .where(
              (painting) => [
                painting.titleArabic,
                painting.title,
                painting.artistArabic,
                painting.artist,
              ].map(normaliseSearchText).any((value) => value.contains(query)),
            )
            .take(6)
            .toList(growable: false);
    final translatedLoading =
        museumPaintings.isLoading && museumPaintings.asData == null;

    if (works.isEmpty &&
        artists.isEmpty &&
        translated.isEmpty &&
        _onlineResults.isEmpty &&
        !translatedLoading &&
        !_onlineLoading &&
        !_onlineFailed) {
      return const Center(
        child: Text(
          'لم نجد لوحات أو فنانين بهذا الاسم.',
          style: TextStyle(color: WashijColors.mist),
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      children: [
        if (works.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsetsDirectional.only(start: 12, top: 8, bottom: 4),
            child: Text(
              'لوحات',
              style: TextStyle(color: WashijColors.mutedSky),
            ),
          ),
          for (final work in works)
            FocusRing(
              child: ListTile(
                dense: true,
                title: Text(work.titleAr),
                subtitle: Text(
                  '${work.titleOrig} · ${catalog.artists[work.artistId]?.nameAr ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                ),
                onTap: () => _onSelect('/artwork/${work.id}'),
              ),
            ),
        ],
        if (translated.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsetsDirectional.only(start: 12, top: 8, bottom: 4),
            child: Text(
              'لوحات مترجمة',
              style: TextStyle(color: WashijColors.mutedSky),
            ),
          ),
          for (final painting in translated)
            FocusRing(
              child: ListTile(
                dense: true,
                title: Text(painting.titleArabic),
                subtitle: Text(
                  '${painting.title} · ${painting.artistArabic}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                ),
                onTap: () => _onSelect('/artwork/museum/${painting.id}'),
              ),
            ),
        ],
        if (_onlineResults.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsetsDirectional.only(start: 12, top: 8, bottom: 4),
            child: Text(
              'لوحات من متحف كليفلاند',
              style: TextStyle(color: WashijColors.mutedSky),
            ),
          ),
          for (final painting in _onlineResults)
            FocusRing(
              child: ListTile(
                dense: true,
                title: Text(painting.displayTitle),
                subtitle: Text(
                  '${painting.title} · ${painting.artistDisplay}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                ),
                onTap: () => _onSelect('/artwork/cleveland/${painting.id}'),
              ),
            ),
        ],
        if (translatedLoading)
          const _SearchLoadingStatus(
            message: 'جارٍ البحث في اللوحات المترجمة…',
          ),
        if (_onlineLoading)
          const _SearchLoadingStatus(message: 'جارٍ البحث في مجموعات المتاحف…'),
        if (_onlineFailed)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 12, top: 8),
            child: TextButton.icon(
              onPressed: _retryOnlineSearch,
              icon: const Icon(Icons.refresh),
              label: const Text('تعذّر البحث في مجموعة المتحف. أعد المحاولة'),
            ),
          ),
        if (artists.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsetsDirectional.only(start: 12, top: 8, bottom: 4),
            child: Text(
              'فنانون',
              style: TextStyle(color: WashijColors.mutedSky),
            ),
          ),
          for (final artist in artists)
            FocusRing(
              child: ListTile(
                dense: true,
                title: Text(artist.nameAr),
                subtitle: Text(artist.nameOrig),
                onTap: () => _onSelect('/artist/${artist.id}'),
              ),
            ),
        ],
      ],
    );
  }

  void _onSelect(String location) {
    _searchDebounce?.cancel();
    widget.onSelect(location);
  }
}

class _SearchLoadingStatus extends StatelessWidget {
  const _SearchLoadingStatus({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: WashijColors.starYellow,
          ),
        ),
        const SizedBox(width: 10),
        Text(message, style: const TextStyle(color: WashijColors.mist)),
      ],
    ),
  );
}
