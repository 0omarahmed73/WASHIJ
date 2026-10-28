import 'package:flutter_test/flutter_test.dart';
import 'package:washij/data/bundled_source.dart';
import 'package:washij/data/catalog.dart';
import 'package:washij/data/fact_cache.dart';
import 'package:washij/data/models/artist.dart';
import 'package:washij/data/models/artwork.dart';
import 'package:washij/data/models/movement.dart';
import 'package:washij/data/models/period.dart';
import 'package:washij/data/models/remote_artwork_data.dart';
import 'package:washij/data/remote_source.dart';
import 'package:washij/data/repository.dart';

void main() {
  final now = DateTime.utc(2026, 10, 28);

  test(
    'remote facts win while bundled editorial stays authoritative',
    () async {
      final repository = _repository(
        now: now,
        remote: _FakeRemote(
          records: {
            'Q1': _remote(
              now,
              titleAr: 'عنوان من ويكيداتا',
              medium: 'زيت على خشب',
            ),
          },
        ),
      );

      final result = await repository.load();
      final work = result.artworks.single;

      expect(work.titleAr, 'عنوان من ويكيداتا');
      expect(work.medium, 'زيت على خشب');
      expect(work.poem, 'بيت تحريري');
      expect(work.story, ['حكاية تحريرية']);
      expect(work.interpretations.single.attribution, 'ناقد فني');
    },
  );

  test('bundled values remain when remote requests fail', () async {
    final repository = _repository(now: now, remote: _FakeRemote(throws: true));

    final work = (await repository.load()).artworks.single;

    expect(work.titleAr, 'عنوان اللوحة');
    expect(work.medium, 'زيت على قماش');
    expect(work.image!.remoteUrl, isNull);
  });

  test('stale cached values are used when remote requests fail', () async {
    final stale = _remote(
      now.subtract(const Duration(days: 8)),
      titleAr: 'عنوان محفوظ',
      collection: 'مجموعة محفوظة',
    );
    final repository = _repository(
      now: now,
      remote: _FakeRemote(throws: true),
      cache: _FakeCache({'Q1': stale}),
    );

    final work = (await repository.load()).artworks.single;

    expect(work.titleAr, 'عنوان محفوظ');
    expect(work.collection, 'مجموعة محفوظة');
  });

  test('fresh cache avoids an unnecessary request', () async {
    final remote = _FakeRemote(throws: true);
    final repository = _repository(
      now: now,
      remote: remote,
      cache: _FakeCache({
        'Q1': _remote(now.subtract(const Duration(days: 1)), titleAr: 'حديثة'),
      }),
    );

    final work = (await repository.load()).artworks.single;

    expect(work.titleAr, 'حديثة');
    expect(remote.called, isFalse);
  });
}

ArtworkRepository _repository({
  required DateTime now,
  required ArtworkRemoteSource remote,
  ArtworkCache? cache,
}) => ArtworkRepository(
  bundled: _FakeCatalogSource(_catalog()),
  remote: remote,
  cache: cache ?? _FakeCache(),
  clock: () => now,
);

Catalog _catalog() => Catalog(
  artworks: [
    Artwork(
      id: 'test-work',
      qid: 'Q1',
      titleAr: 'عنوان اللوحة',
      titleOrig: 'Test Painting',
      artistId: 'test-artist',
      movementId: 'test-movement',
      year: 1900,
      dateText: '1900',
      medium: 'زيت على قماش',
      dimensions: '10 × 20 سم',
      collection: 'مجموعة أصلية',
      place: 'مكان أصلي',
      poem: 'بيت تحريري',
      intro: 'مقدمة تحريرية',
      story: const ['حكاية تحريرية'],
      reading: const ['قراءة تحريرية'],
      details: const [],
      interpretations: const [
        Interpretation(text: 'تفسير', attribution: 'ناقد فني'),
      ],
      related: const [],
      sources: const [],
      image: const ArtworkImage(
        asset: 'assets/img/test.jpg',
        width: 20,
        height: 10,
      ),
      credit: const ArtworkCredit(
        author: 'فنان',
        licence: 'Public domain',
        fileUrl: 'https://commons.wikimedia.org/wiki/File:Test.jpg',
        articleUrl: 'https://ar.wikipedia.org/wiki/Test',
        attribution: 'مصدر',
      ),
      commonsFile: 'Test.jpg',
      wikipediaTitle: 'Test',
    ),
  ],
  artists: const {
    'test-artist': Artist(
      id: 'test-artist',
      nameAr: 'فنان',
      nameOrig: 'Artist',
      born: '1800',
      died: '1900',
      place: '',
      leadArtworkId: 'test-work',
      movementIds: ['test-movement'],
      bio: '',
      style: '',
    ),
  },
  movements: const {
    'test-movement': Movement(
      id: 'test-movement',
      nameAr: 'مدرسة',
      nameOrig: 'Movement',
      period: '',
      place: '',
      line: '',
      intro: '',
      traits: [],
    ),
  },
  periods: const [
    Period(
      id: 'p4',
      labelAr: 'القرن 20',
      minYear: 1900,
      maxYearExclusive: null,
    ),
  ],
);

RemoteArtworkData _remote(
  DateTime fetchedAt, {
  String? titleAr,
  String? medium,
  String? collection,
}) => RemoteArtworkData(
  qid: 'Q1',
  fetchedAt: fetchedAt,
  titleAr: titleAr,
  medium: medium,
  collection: collection,
);

class _FakeCatalogSource implements CatalogSource {
  const _FakeCatalogSource(this.catalog);
  final Catalog catalog;

  @override
  Future<Catalog> load() async => catalog;
}

class _FakeRemote implements ArtworkRemoteSource {
  _FakeRemote({this.records = const {}, this.throws = false});
  final Map<String, RemoteArtworkData> records;
  final bool throws;
  bool called = false;

  @override
  Future<Map<String, RemoteArtworkData>> fetchFor(
    List<Artwork> artworks,
  ) async {
    called = true;
    if (throws) throw StateError('offline');
    return records;
  }
}

class _FakeCache implements ArtworkCache {
  _FakeCache([Map<String, RemoteArtworkData>? initial])
    : values = {...?initial};

  final Map<String, RemoteArtworkData> values;

  @override
  Future<Map<String, RemoteArtworkData>> readAll(Iterable<String> qids) async =>
      {for (final qid in qids) qid: ?values[qid]};

  @override
  Future<void> writeAll(Map<String, RemoteArtworkData> records) async {
    values.addAll(records);
  }
}
