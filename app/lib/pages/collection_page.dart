import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/arabic_normalise.dart';
import '../data/catalog.dart';
import '../data/models/cleveland_artwork.dart';
import '../data/models/museum_painting.dart';
import '../state/collection_state.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/artwork_card.dart';
import '../widgets/cleveland_artwork_card.dart';
import '../widgets/focus_ring.dart';
import '../widgets/museum_page.dart';
import '../widgets/museum_painting_card.dart';
import '../widgets/page_width.dart';
import '../widgets/section_header.dart';

class CollectionPage extends ConsumerStatefulWidget {
  const CollectionPage({super.key, required this.queryParameters});

  final Map<String, String> queryParameters;

  @override
  ConsumerState<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends ConsumerState<CollectionPage> {
  static const _onlinePageSize = 12;

  late final TextEditingController _searchController;
  final List<ClevelandArtwork> _moreOnlinePaintings = [];
  var _nextOnlinePage = 2;
  var _loadingOnlineMore = false;
  var _hasMoreOnlinePaintings = true;
  var _onlineMoreFailed = false;
  var _museumShown = 6;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.queryParameters['q'] ?? '',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(collectionStateProvider.notifier)
            .syncFromQuery(widget.queryParameters);
      }
    });
  }

  @override
  void didUpdateWidget(covariant CollectionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mapEquals(oldWidget.queryParameters, widget.queryParameters)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(collectionStateProvider.notifier)
              .syncFromQuery(widget.queryParameters);
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMoreOnline(WidgetRef ref) async {
    if (_loadingOnlineMore || !_hasMoreOnlinePaintings) return;
    setState(() {
      _loadingOnlineMore = true;
      _onlineMoreFailed = false;
    });
    try {
      final paintings = await ref
          .read(clevelandRemoteSourceProvider)
          .fetchPaintings(page: _nextOnlinePage, limit: _onlinePageSize);
      if (!mounted) return;
      setState(() {
        _moreOnlinePaintings.addAll(paintings);
        _nextOnlinePage++;
        _hasMoreOnlinePaintings = paintings.length == _onlinePageSize;
        _loadingOnlineMore = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _loadingOnlineMore = false;
        _onlineMoreFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(collectionStateProvider, (previous, next) {
      if (previous?.query != next.query) _museumShown = 6;
      if (_searchController.text != next.query) {
        _searchController.value = TextEditingValue(
          text: next.query,
          selection: TextSelection.collapsed(offset: next.query.length),
        );
      }
    });
    final state = ref.watch(collectionStateProvider);
    final catalog = ref.watch(catalogProvider);
    return MuseumPage(
      slivers: [
        SliverToBoxAdapter(
          child: PageWidth(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(top: 48, bottom: 64),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(title: 'اللوحات'),
                  Text(
                    'كل عمل بداية لخيط جديد',
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: WashijColors.mist),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      labelText: 'ابحث بعنوان اللوحة أو اسم الفنان',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => _change(
                      context,
                      ref,
                      (controller) => controller.setQuery(value),
                    ),
                  ),
                  const SizedBox(height: 16),
                  catalog.when(
                    data: (value) => _filters(context, ref, value, state),
                    loading: () => const LinearProgressIndicator(),
                    error: (error, stackTrace) => const SizedBox.shrink(),
                  ),
                  if (catalog case AsyncData<Catalog>(:final value))
                    _results(context, ref, value, state),
                  if (catalog.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 36),
                      child: Text(
                        'تعذّر تحميل المجموعة. أعد المحاولة بعد قليل.',
                        style: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(color: WashijColors.danger),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _filters(
    BuildContext context,
    WidgetRef ref,
    Catalog catalog,
    CollectionState state,
  ) {
    final periodById = {
      for (final period in catalog.periods) period.id: period,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final fieldWidth = constraints.maxWidth < 520
                ? constraints.maxWidth
                : (constraints.maxWidth - 24) / 2;
            return Wrap(
              spacing: 24,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: fieldWidth,
                  child: _dropdown(
                    label: 'المدرسة الفنية',
                    value: state.movementId,
                    options: {
                      for (final movement in catalog.movements.values)
                        movement.id: movement.nameAr,
                    },
                    onChanged: (value) => _change(
                      context,
                      ref,
                      (controller) => controller.setMovement(value),
                    ),
                  ),
                ),
                SizedBox(
                  width: fieldWidth,
                  child: _dropdown(
                    label: 'الفنان',
                    value: state.artistId,
                    options: {
                      for (final artist in catalog.artists.values)
                        artist.id: artist.nameAr,
                    },
                    onChanged: (value) => _change(
                      context,
                      ref,
                      (controller) => controller.setArtist(value),
                    ),
                  ),
                ),
                SizedBox(
                  width: fieldWidth,
                  child: _dropdown(
                    label: 'الفترة',
                    value: state.periodId,
                    options: {
                      for (final period in catalog.periods)
                        period.id: period.labelAr,
                    },
                    onChanged: (value) => _change(
                      context,
                      ref,
                      (controller) => controller.setPeriod(value),
                    ),
                  ),
                ),
                SizedBox(
                  width: fieldWidth,
                  child: DropdownButtonFormField<CollectionSort>(
                    initialValue: state.sort,
                    decoration: const InputDecoration(labelText: 'ترتيب'),
                    items: const [
                      DropdownMenuItem(
                        value: CollectionSort.dateAsc,
                        child: Text('الأقدم أولًا', maxLines: 1),
                      ),
                      DropdownMenuItem(
                        value: CollectionSort.dateDesc,
                        child: Text('الأحدث أولًا', maxLines: 1),
                      ),
                      DropdownMenuItem(
                        value: CollectionSort.titleAsc,
                        child: Text('العنوان: أ إلى ي', maxLines: 1),
                      ),
                      DropdownMenuItem(
                        value: CollectionSort.titleDesc,
                        child: Text('العنوان: ي إلى أ', maxLines: 1),
                      ),
                    ],
                    isExpanded: true,
                    onChanged: (value) {
                      if (value != null) {
                        _change(
                          context,
                          ref,
                          (controller) => controller.setSort(value),
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
        if (_hasActiveFilters(state)) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (state.query.trim().isNotEmpty)
                _activeChip(
                  'بحث: ${state.query.trim()}',
                  () => _change(
                    context,
                    ref,
                    (controller) => controller.setQuery(''),
                  ),
                ),
              if (state.movementId case final id?)
                _activeChip(
                  catalog.movements[id]?.nameAr ?? id,
                  () => _change(
                    context,
                    ref,
                    (controller) => controller.setMovement(null),
                  ),
                ),
              if (state.artistId case final id?)
                _activeChip(
                  catalog.artists[id]?.nameAr ?? id,
                  () => _change(
                    context,
                    ref,
                    (controller) => controller.setArtist(null),
                  ),
                ),
              if (state.periodId case final id?)
                _activeChip(
                  periodById[id]?.labelAr ?? id,
                  () => _change(
                    context,
                    ref,
                    (controller) => controller.setPeriod(null),
                  ),
                ),
              TextButton.icon(
                onPressed: () =>
                    _change(context, ref, (controller) => controller.reset()),
                icon: const Icon(Icons.restart_alt),
                label: const Text('مسح المرشحات'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required Map<String, String> options,
    required ValueChanged<String?> onChanged,
  }) => DropdownButtonFormField<String?>(
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: [
      DropdownMenuItem<String?>(
        value: null,
        child: Text('كل $label', maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      for (final entry in options.entries)
        DropdownMenuItem<String?>(
          value: entry.key,
          child: Text(
            entry.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
    ],
    onChanged: onChanged,
  );

  Widget _activeChip(String label, VoidCallback onRemove) => FocusRing(
    child: InputChip(
      label: Text(label, overflow: TextOverflow.ellipsis),
      onDeleted: onRemove,
      backgroundColor: WashijColors.indigo,
      side: const BorderSide(color: WashijColors.borderControl),
      deleteIconColor: WashijColors.ivory,
      labelStyle: const TextStyle(color: WashijColors.ivory),
    ),
  );

  Widget _results(
    BuildContext context,
    WidgetRef ref,
    Catalog catalog,
    CollectionState state,
  ) {
    final results = selectCollection(catalog, state);
    final onlinePaintings = ref.watch(clevelandPublicPaintingsProvider);
    final museumPaintings = ref.watch(museumPaintingsProvider);
    final visible = results.take(state.shown).toList(growable: false);
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1100
        ? 4
        : width >= 700
        ? 3
        : 2;
    final pageWidth = width >= 1320 ? 1240.0 : width - (width < 600 ? 40 : 80);
    final cardWidth = (pageWidth - (columns - 1) * 20) / columns;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        SectionHeader(
          title: 'في المجموعة',
          action: Text('${results.length} لوحة'),
        ),
        if (results.isEmpty)
          _emptyResults(context, ref)
        else ...[
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              for (final work in visible)
                if (catalog.artists[work.artistId] case final artist?)
                  SizedBox(
                    width: cardWidth,
                    child: ArtworkCard(artwork: work, artist: artist),
                  ),
            ],
          ),
          if (visible.length < results.length) ...[
            const SizedBox(height: 28),
            Center(
              child: OutlinedButton(
                onPressed: () => ref
                    .read(collectionStateProvider.notifier)
                    .loadMore(results.length),
                child: const Text('تحميل المزيد من اللوحات'),
              ),
            ),
          ],
        ],
        const SizedBox(height: 56),
        museumPaintings.when(
          data: (paintings) {
            final matches = _matchingMuseumPaintings(paintings, state.query);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  title: 'لوحات مترجمة من مجموعات المتاحف',
                  action: Text('${matches.length} لوحة'),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'ترجمات عربية مصحّحة آليًا، لكنها لم تراجع تحريرياً بعد. تعمل خانة البحث هنا، وتظهر إحالة كل وصف ورخصته في صفحة اللوحة.',
                    style: TextStyle(color: WashijColors.mist),
                  ),
                ),
                if (matches.isEmpty)
                  _OnlinePaintingsStatus(
                    message: state.query.trim().isEmpty
                        ? 'لا توجد لوحات مترجمة متاحة.'
                        : 'لم نجد لوحات مترجمة تطابق هذا البحث.',
                  )
                else ...[
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      for (final painting in matches.take(_museumShown))
                        SizedBox(
                          width: cardWidth,
                          child: MuseumPaintingCard(painting: painting),
                        ),
                    ],
                  ),
                  if (_museumShown < matches.length) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: OutlinedButton(
                        onPressed: () => setState(() {
                          _museumShown = (_museumShown + 6).clamp(
                            0,
                            matches.length,
                          );
                        }),
                        child: const Text('تحميل المزيد من اللوحات المترجمة'),
                      ),
                    ),
                  ],
                ],
              ],
            );
          },
          loading: () => const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(title: 'لوحات مترجمة من مجموعات المتاحف'),
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  'ترجمات عربية مصحّحة آليًا، لكنها لم تراجع تحريرياً بعد. تعمل خانة البحث هنا، وتظهر إحالة كل وصف ورخصته في صفحة اللوحة.',
                  style: TextStyle(color: WashijColors.mist),
                ),
              ),
              _OnlinePaintingsLoading(message: 'جارٍ تحميل اللوحات المترجمة…'),
            ],
          ),
          error: (error, stackTrace) => _OnlinePaintingsStatus(
            message: 'تعذّر تحميل مجموعة اللوحات المترجمة.',
            onRetry: () => ref.invalidate(museumPaintingsProvider),
          ),
        ),
        const SizedBox(height: 56),
        const SectionHeader(title: 'لوحات إضافية من متحف كليفلاند للفنون'),
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            'لوحات بصور مرخصة CC0 من بيانات المتحف. قد يظهر الاسم الأصلي إذا لم يتوفر عنوان عربي مطابق في ويكي بيانات.',
            style: TextStyle(color: WashijColors.mist),
          ),
        ),
        onlinePaintings.when(
          data: (paintings) => paintings.isEmpty
              ? const _OnlinePaintingsStatus(
                  message: 'لا توجد لوحات إضافية متاحة الآن.',
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        for (final painting in [
                          ...paintings,
                          ..._moreOnlinePaintings,
                        ])
                          SizedBox(
                            width: cardWidth,
                            child: ClevelandArtworkCard(artwork: painting),
                          ),
                      ],
                    ),
                    if (_onlineMoreFailed) ...[
                      const SizedBox(height: 14),
                      const _OnlinePaintingsStatus(
                        message: 'تعذّر تحميل المزيد من اللوحات.',
                      ),
                    ],
                    if (paintings.length == _onlinePageSize &&
                        _hasMoreOnlinePaintings) ...[
                      const SizedBox(height: 24),
                      Center(
                        child: OutlinedButton(
                          onPressed: _loadingOnlineMore
                              ? null
                              : () => _loadMoreOnline(ref),
                          child: _loadingOnlineMore
                              ? const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox.square(
                                      dimension: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: WashijColors.starYellow,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text('جارٍ تحميل المزيد…'),
                                  ],
                                )
                              : Text(
                                  _onlineMoreFailed
                                      ? 'إعادة المحاولة'
                                      : 'تحميل المزيد من لوحات المتحف',
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
          loading: () => const _OnlinePaintingsLoading(
            message: 'جارٍ تحميل لوحات المتحف…',
          ),
          error: (error, stackTrace) => _OnlinePaintingsStatus(
            message: 'تعذّر تحميل مجموعة المتحف الآن.',
            onRetry: () => ref.invalidate(clevelandPublicPaintingsProvider),
          ),
        ),
      ],
    );
  }

  List<MuseumPainting> _matchingMuseumPaintings(
    List<MuseumPainting> paintings,
    String query,
  ) {
    final normalizedQuery = normaliseSearchText(query);
    if (normalizedQuery.isEmpty) return paintings;
    return paintings
        .where((painting) {
          return [
            painting.titleArabic,
            painting.title,
            painting.artistArabic,
            painting.artist,
          ].any(
            (value) => normaliseSearchText(value).contains(normalizedQuery),
          );
        })
        .toList(growable: false);
  }

  Widget _emptyResults(BuildContext context, WidgetRef ref) => Container(
    padding: const EdgeInsets.all(28),
    decoration: const BoxDecoration(
      color: WashijColors.deepBlue,
      border: Border.fromBorderSide(BorderSide(color: WashijColors.hairline)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'لم نجد لوحات تطابق هذا البحث',
          style: WashijTypography.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        const Text(
          'لم نجدها في المجموعة المختارة. تظهر النتائج من المتاحف في الأقسام التالية.',
          style: TextStyle(color: WashijColors.mist),
        ),
        const SizedBox(height: 18),
        OutlinedButton(
          onPressed: () =>
              _change(context, ref, (controller) => controller.reset()),
          child: const Text('مسح المرشحات'),
        ),
      ],
    ),
  );

  void _change(
    BuildContext context,
    WidgetRef ref,
    void Function(CollectionController) update,
  ) {
    final controller = ref.read(collectionStateProvider.notifier);
    update(controller);
    final params = ref.read(collectionStateProvider).toQueryParameters();
    final location = Uri(
      path: '/artworks',
      queryParameters: params.isEmpty ? null : params,
    ).toString();
    context.replace(location);
  }

  bool _hasActiveFilters(CollectionState state) =>
      state.query.trim().isNotEmpty ||
      state.movementId != null ||
      state.artistId != null ||
      state.periodId != null;
}

class _OnlinePaintingsStatus extends StatelessWidget {
  const _OnlinePaintingsStatus({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message, style: const TextStyle(color: WashijColors.mist)),
        if (onRetry != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ],
    ),
  );
}

class _OnlinePaintingsLoading extends StatelessWidget {
  const _OnlinePaintingsLoading({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: WashijColors.starYellow,
            ),
          ),
          const SizedBox(width: 12),
          Text(message, style: const TextStyle(color: WashijColors.mist)),
        ],
      ),
    ),
  );
}
