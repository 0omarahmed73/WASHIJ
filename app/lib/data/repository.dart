import 'catalog.dart';
import 'bundled_source.dart';
import 'fact_cache.dart';
import 'models/remote_artwork_data.dart';
import 'remote_source.dart';

class ArtworkRepository {
  ArtworkRepository({
    required this._bundled,
    required this._remote,
    required this._cache,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const _refreshAfter = Duration(days: 7);
  final CatalogSource _bundled;
  final ArtworkRemoteSource _remote;
  final ArtworkCache _cache;
  final DateTime Function() _clock;

  Future<Catalog> load({Catalog? initialCatalog}) async {
    final catalog = initialCatalog ?? await _bundled.load();
    final qids = catalog.artworks
        .map((work) => work.qid)
        .toList(growable: false);
    Map<String, RemoteArtworkData> cached = const {};
    try {
      cached = await _cache.readAll(qids);
    } on Object {
      // Bundled data remains usable when browser storage is unavailable.
    }

    final now = _clock().toUtc();
    final staleWorks = catalog.artworks
        .where((work) {
          final record = cached[work.qid];
          return record == null ||
              now.difference(record.fetchedAt) >= _refreshAfter;
        })
        .toList(growable: false);

    Map<String, RemoteArtworkData> fetched = const {};
    if (staleWorks.isNotEmpty) {
      try {
        fetched = await _remote.fetchFor(staleWorks);
      } on Object {
        fetched = const {};
      }
    }

    final updated = <String, RemoteArtworkData>{};
    for (final entry in fetched.entries) {
      final previous = cached[entry.key];
      updated[entry.key] = previous == null
          ? entry.value
          : previous.merge(entry.value);
    }
    if (updated.isNotEmpty) {
      try {
        await _cache.writeAll(updated);
      } on Object {
        // A cache write failure does not prevent this visit from rendering.
      }
    }

    final records = {...cached, ...updated};
    return Catalog(
      artworks: catalog.artworks
          .map((work) => records[work.qid]?.applyTo(work) ?? work)
          .toList(growable: false),
      artists: catalog.artists,
      movements: catalog.movements,
      periods: catalog.periods,
    );
  }
}
