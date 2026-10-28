import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../data/art_reading_repository.dart';
import '../data/bundled_source.dart';
import '../data/catalog.dart';
import '../data/cleveland_remote_source.dart';
import '../data/fact_cache.dart';
import '../data/models/cleveland_artwork.dart';
import '../data/models/art_reading.dart';
import '../data/models/museum_painting.dart';
import '../data/museum_paintings_repository.dart';
import '../data/remote_source.dart';
import '../data/repository.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final artReadingsProvider = FutureProvider<List<ArtReading>>((ref) async {
  final repository = ArtReadingRepository(
    client: ref.watch(httpClientProvider),
  );
  return repository.load();
});

final museumPaintingsProvider = FutureProvider<List<MuseumPainting>>((ref) {
  return MuseumPaintingsRepository().load();
});

final clevelandRemoteSourceProvider = Provider<ClevelandRemoteSource>((ref) {
  return ClevelandRemoteSource(client: ref.watch(httpClientProvider));
});

final clevelandPublicPaintingsProvider = FutureProvider<List<ClevelandArtwork>>(
  (ref) {
    return ref.watch(clevelandRemoteSourceProvider).fetchPaintings();
  },
);

final clevelandArtworkProvider = FutureProvider.family<ClevelandArtwork?, int>((
  ref,
  id,
) {
  final cached = ref.watch(clevelandPublicPaintingsProvider).asData?.value;
  for (final artwork in cached ?? const <ClevelandArtwork>[]) {
    if (artwork.id == id) return Future.value(artwork);
  }
  return ref.watch(clevelandRemoteSourceProvider).fetchPaintingById(id);
});

final bundledSourceProvider = Provider<BundledSource>(
  (ref) => const BundledSource(),
);

final artworkRemoteSourceProvider = Provider<ArtworkRemoteSource>((ref) {
  final source = RemoteSource(client: ref.watch(httpClientProvider));
  return source;
});

final artworkCacheProvider = Provider<ArtworkCache>((ref) => const FactCache());

final artworkRepositoryProvider = Provider<ArtworkRepository>(
  (ref) => ArtworkRepository(
    bundled: ref.watch(bundledSourceProvider),
    remote: ref.watch(artworkRemoteSourceProvider),
    cache: ref.watch(artworkCacheProvider),
  ),
);

final catalogProvider = AsyncNotifierProvider<CatalogController, Catalog>(
  CatalogController.new,
);

class CatalogController extends AsyncNotifier<Catalog> {
  var _requestId = 0;

  @override
  Future<Catalog> build() async {
    final bundled = await ref.watch(bundledSourceProvider).load();
    final repository = ref.watch(artworkRepositoryProvider);
    final requestId = ++_requestId;
    ref.onDispose(() => _requestId++);
    unawaited(_refresh(requestId, repository, bundled));
    return bundled;
  }

  Future<void> _refresh(
    int requestId,
    ArtworkRepository repository,
    Catalog bundled,
  ) async {
    try {
      final fresh = await repository.load(initialCatalog: bundled);
      if (_requestId == requestId) state = AsyncData(fresh);
    } on Object catch (error, stackTrace) {
      if (_requestId == requestId) {
        state = AsyncError(error, stackTrace);
      }
    }
  }
}
