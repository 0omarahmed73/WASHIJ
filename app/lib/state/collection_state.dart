import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/arabic_normalise.dart';
import '../data/catalog.dart';
import '../data/models/artwork.dart';

enum CollectionSort { dateAsc, dateDesc, titleAsc, titleDesc }

extension CollectionSortParameter on CollectionSort {
  String get parameter => switch (this) {
    CollectionSort.dateAsc => 'date-asc',
    CollectionSort.dateDesc => 'date-desc',
    CollectionSort.titleAsc => 'title-asc',
    CollectionSort.titleDesc => 'title-desc',
  };

  static CollectionSort parse(String? value) => switch (value) {
    'date-desc' => CollectionSort.dateDesc,
    'title-asc' => CollectionSort.titleAsc,
    'title-desc' => CollectionSort.titleDesc,
    _ => CollectionSort.dateAsc,
  };
}

class CollectionState {
  const CollectionState({
    this.query = '',
    this.movementId,
    this.artistId,
    this.periodId,
    this.sort = CollectionSort.dateAsc,
    this.shown = 6,
  });

  final String query;
  final String? movementId;
  final String? artistId;
  final String? periodId;
  final CollectionSort sort;
  final int shown;

  CollectionState copyWith({
    String? query,
    String? movementId,
    String? artistId,
    String? periodId,
    CollectionSort? sort,
    int? shown,
    bool clearMovement = false,
    bool clearArtist = false,
    bool clearPeriod = false,
  }) => CollectionState(
    query: query ?? this.query,
    movementId: clearMovement ? null : movementId ?? this.movementId,
    artistId: clearArtist ? null : artistId ?? this.artistId,
    periodId: clearPeriod ? null : periodId ?? this.periodId,
    sort: sort ?? this.sort,
    shown: shown ?? this.shown,
  );

  factory CollectionState.fromQuery(Map<String, String> queryParameters) =>
      CollectionState(
        query: queryParameters['q'] ?? '',
        movementId: queryParameters['movement'],
        artistId: queryParameters['artist'],
        periodId: queryParameters['period'],
        sort: CollectionSortParameter.parse(queryParameters['sort']),
      );

  Map<String, String> toQueryParameters() => {
    'q': ?(query.trim().isEmpty ? null : query.trim()),
    'movement': ?movementId,
    'artist': ?artistId,
    'period': ?periodId,
    'sort': ?(sort == CollectionSort.dateAsc ? null : sort.parameter),
  };
}

class CollectionController extends Notifier<CollectionState> {
  @override
  CollectionState build() => const CollectionState();

  void syncFromQuery(Map<String, String> queryParameters) {
    state = CollectionState.fromQuery(queryParameters);
  }

  void setQuery(String value) => state = state.copyWith(query: value, shown: 6);

  void setMovement(String? value) => state = state.copyWith(
    movementId: value,
    clearMovement: value == null,
    shown: 6,
  );

  void setArtist(String? value) => state = state.copyWith(
    artistId: value,
    clearArtist: value == null,
    shown: 6,
  );

  void setPeriod(String? value) => state = state.copyWith(
    periodId: value,
    clearPeriod: value == null,
    shown: 6,
  );

  void setSort(CollectionSort value) => state = state.copyWith(sort: value);

  void loadMore(int total) =>
      state = state.copyWith(shown: (state.shown + 6).clamp(0, total));

  void reset() => state = CollectionState(sort: state.sort);
}

final collectionStateProvider =
    NotifierProvider<CollectionController, CollectionState>(
      CollectionController.new,
    );

List<Artwork> selectCollection(Catalog catalog, CollectionState state) {
  final query = normaliseSearchText(state.query);
  final filtered = catalog.artworks.where((work) {
    if (state.movementId != null && work.movementId != state.movementId) {
      return false;
    }
    if (state.artistId != null && work.artistId != state.artistId) return false;
    if (state.periodId != null) {
      final period = catalog.periods.where((item) => item.id == state.periodId);
      if (period.isEmpty || !period.first.contains(work.year)) return false;
    }
    if (query.isEmpty) return true;
    final artist = catalog.artists[work.artistId];
    final searchable = [
      work.titleAr,
      work.titleOrig,
      if (artist != null) artist.nameAr,
      if (artist != null) artist.nameOrig,
    ].map(normaliseSearchText);
    return searchable.any((value) => value.contains(query));
  }).toList();

  filtered.sort((a, b) {
    final titleComparison = normaliseSearchText(a.titleAr)
        .compareTo(normaliseSearchText(b.titleAr));
    final yearComparison = a.year.compareTo(b.year);
    return switch (state.sort) {
      CollectionSort.dateAsc =>
        yearComparison == 0 ? titleComparison : yearComparison,
      CollectionSort.dateDesc =>
        yearComparison == 0 ? titleComparison : -yearComparison,
      CollectionSort.titleAsc => titleComparison,
      CollectionSort.titleDesc => -titleComparison,
    };
  });
  return filtered;
}
