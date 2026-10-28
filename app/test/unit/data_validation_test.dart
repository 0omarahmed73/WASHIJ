import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:washij/data/bundled_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'bundled catalogue meets its content and relationship invariants',
    () async {
      final catalog = await const BundledSource().load();
      final artworkIds = catalog.artworks.map((work) => work.id).toSet();

      expect(catalog.artworks, hasLength(14));
      expect(catalog.artists, hasLength(12));
      expect(catalog.movements, hasLength(9));
      expect(catalog.periods, hasLength(4));

      for (final work in catalog.artworks) {
        expect(catalog.artists, contains(work.artistId));
        expect(catalog.movements, contains(work.movementId));
        expect(work.poem.trim(), isNotEmpty);
        expect(work.story, isNotEmpty);
        expect(work.credit.articleUrl, startsWith('https://'));
        if (work.image != null) {
          expect(work.credit.author.trim(), isNotEmpty);
          expect(work.credit.licence.trim(), isNotEmpty);
          expect(
            work.credit.fileUrl,
            startsWith('https://commons.wikimedia.org/'),
          );
        }
        for (final interpretation in work.interpretations) {
          expect(interpretation.attribution.trim(), isNotEmpty);
        }
        for (final related in work.related) {
          expect(artworkIds, contains(related.artworkId));
          expect(related.reason.trim(), isNotEmpty);
        }
      }

      final persistence = catalog.artwork('persistence-of-memory');
      expect(persistence, isNotNull);
      expect(persistence!.image, isNull);
    },
  );

  test('bundled data contains no commerce language', () async {
    final dataFiles = [
      'assets/data/works.json',
      'assets/data/artists.json',
      'assets/data/movements.json',
      'assets/data/periods.json',
    ];
    final decodedFiles = <Object?>[];
    for (final file in dataFiles) {
      decodedFiles.add(jsonDecode(await rootBundle.loadString(file)));
    }
    final text = _flatten(decodedFiles).toLowerCase();
    expect(
      RegExp(r'\b(price|cart|bid|purchase|checkout|buy|sale)\b').hasMatch(text),
      isFalse,
    );
    expect(
      RegExp(r'(?:^|[\s،.])(?:سعر|شراء|اشتر\w*|سلة|مزاد|دفع|للبيع)(?:$|[\s،.])')
          .hasMatch(text),
      isFalse,
    );
  });
}

String _flatten(Object? value) {
  if (value is Map) return value.values.map(_flatten).join(' ');
  if (value is List) return value.map(_flatten).join(' ');
  return value?.toString() ?? '';
}
