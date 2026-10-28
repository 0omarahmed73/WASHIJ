import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:washij/data/models/cleveland_artwork.dart';
import 'package:washij/data/models/shareable_painting.dart';
import 'package:washij/data/painting_export.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const cleveland = ClevelandArtwork(
    id: 94979,
    accessionNumber: '1915.534',
    title: 'Nathaniel Hurd',
    artistDisplay: 'John Singleton Copley',
    dateDisplay: 'c. 1765',
    mediumDisplay: 'oil on canvas',
    dimensions: '',
    creditLine: 'Gift of the Hurd family',
    imageUrl: 'https://openaccess-cdn.clevelandart.org/1915.534/web.jpg',
    sourceUrl: 'https://www.clevelandart.org/art/1915.534',
  );

  // A 1x1 PNG.
  final png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/q842iQAAAABJRU5ErkJggg==',
  );

  test('file stems are safe for every platform', () {
    final painting = ShareablePainting.fromCleveland(cleveland);
    expect(painting.fileStem, 'washij-cma-94979');
    expect(
      const ShareablePainting(
        id: '../x y',
        titleArabic: 'a',
        titleOriginal: 'a',
        artistArabic: 'a',
        artistOriginal: 'a',
        dateText: '',
        creditLine: '',
        attribution: '',
      ).fileStem,
      'washij-xy',
    );
  });

  test('online image bytes are passed through untouched', () async {
    final client = MockClient(
      (request) async =>
          http.Response.bytes(png, 200, headers: {'content-type': 'image/png'}),
    );
    final file = await PaintingExport(client: client)
        .loadImage(ShareablePainting.fromCleveland(cleveland));
    expect(file.bytes, png);
    expect(file.extension, 'png');
    expect(file.mimeType, 'image/png');
  });

  test('a failed download throws when there is no bundled copy', () async {
    final client = MockClient((request) async => http.Response('no', 404));
    expect(
      PaintingExport(client: client)
          .loadImage(ShareablePainting.fromCleveland(cleveland)),
      throwsA(isA<StateError>()),
    );
  });

  test('a failed download falls back to the bundled image', () async {
    final client = MockClient((request) async => http.Response('no', 500));
    final painting = ShareablePainting(
      id: 'aic-1',
      titleArabic: 'عمل',
      titleOriginal: 'Work',
      artistArabic: 'فنان',
      artistOriginal: 'Artist',
      dateText: '1900',
      creditLine: '',
      attribution: 'Test',
      imageAsset: 'assets/images/museum_paintings/aic-61151.webp',
      imageUrl: 'https://www.artic.edu/iiif/2/x/full/843,/0/default.jpg',
    );
    final file = await PaintingExport(client: client).loadImage(painting);
    expect(file.extension, 'webp');
    expect(file.bytes.length, greaterThan(1000));
  });

  test('the card is a 1080 x 1350 PNG', () async {
    final card = await PaintingExport().renderCard(
      ShareablePainting.fromCleveland(cleveland),
      await _samplePng(),
    );
    expect(card.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]);
    final data = ByteData.sublistView(card);
    expect(data.getUint32(16), 1080);
    expect(data.getUint32(20), 1350);
  });

  test('the asset used above is bundled', () async {
    final data = await rootBundle.load(
      'assets/images/museum_paintings/aic-61151.webp',
    );
    expect(data.lengthInBytes, greaterThan(1000));
  });
}

Future<Uint8List> _samplePng() async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawRect(
    const Rect.fromLTWH(0, 0, 40, 30),
    Paint()..color = const Color(0xFF884422),
  );
  final image = await recorder.endRecording().toImage(40, 30);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}
