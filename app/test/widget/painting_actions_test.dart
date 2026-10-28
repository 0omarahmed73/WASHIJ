import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:washij/data/models/museum_painting.dart';
import 'package:washij/state/providers.dart';
import 'package:washij/widgets/painting_lightbox.dart';

import '../support/test_catalog.dart';

final _painting = MuseumPainting.fromJson({
  'id': 'aic-61151',
  'source': 'Art Institute of Chicago',
  'title': 'Portrait',
  'title_ar': 'بورتريه',
  'artist': 'Artist',
  'artist_ar': 'فنان',
  'date': '1810',
  'date_ar': '1810',
  'medium': 'Oil',
  'medium_ar': 'زيت',
  'dimensions': '',
  'origin': '',
  'origin_ar': '',
  'credit': 'Gift',
  'page': 'https://www.artic.edu/artworks/61151',
  'image': 'https://www.artic.edu/iiif/2/x/full/843,/0/default.jpg',
  'image_asset': 'assets/images/museum_paintings/aic-61151.webp',
  'description_ar': 'وصف',
  'licence': 'Description CC BY 4.0; public-domain artwork',
  'translation': 'test',
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeTestCatalog);

  for (final width in [390.0, 820.0, 1280.0]) {
    testWidgets(
      'painting page shows zoom, download and share at ${width.toInt()}px',
      (tester) async {
        setTestViewport(tester, width);
        // The page's loading spinner never settles, so pump by fixed steps.
        await tester.pumpWidget(
          washijTestApp(
            testCatalog,
            overrides: [
              museumPaintingsProvider.overrideWith((ref) async => [_painting]),
            ],
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        goToRoute(tester, '/artwork/museum/aic-61151');
        await tester.pump(const Duration(milliseconds: 500));
        // The app's start-up splash overlay blocks taps for the first 3.3 seconds.
        await tester.pump(const Duration(seconds: 4));
        for (var i = 0; i < 50; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 100)),
          );
          await tester.pump();
          if (find.text('تكبير الصورة').evaluate().isNotEmpty) break;
        }
        await tester.pump(const Duration(milliseconds: 500));

        for (final label in [
          'تكبير الصورة',
          'تنزيل الصورة',
          'مشاركة الصورة',
          'تنزيل البطاقة',
          'مشاركة البطاقة',
        ]) {
          expect(find.text(label), findsOneWidget, reason: label);
        }
        expect(tester.takeException(), isNull);

        await tester.ensureVisible(find.text('تكبير الصورة'));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.tap(find.text('تكبير الصورة'));
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(PaintingLightbox), findsOneWidget);
        // The container is sized to the painting once its image has decoded.
        for (var i = 0; i < 50; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 100)),
          );
          await tester.pump();
          if (find.byType(InteractiveViewer).evaluate().isNotEmpty) break;
        }
        expect(find.byType(InteractiveViewer), findsOneWidget);

        await tester.tap(find.byTooltip('إغلاق التكبير'));
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(PaintingLightbox), findsNothing);
      },
    );
  }

  for (final width in [390.0, 1280.0]) {
    testWidgets(
      'curated painting page has download and share at ${width.toInt()}px',
      (tester) async {
        setTestViewport(tester, width);
        await tester.pumpWidget(washijTestApp(testCatalog));
        await tester.pump(const Duration(seconds: 4));
        goToRoute(tester, '/artwork/starry-night');
        await tester.pump(const Duration(milliseconds: 800));

        for (final label in [
          'تنزيل الصورة',
          'مشاركة الصورة',
          'تنزيل البطاقة',
          'مشاركة البطاقة',
        ]) {
          expect(find.text(label), findsOneWidget, reason: label);
        }
        // The page's own zoom button stays; no duplicate zoom control is added.
        expect(find.text('تكبير اللوحة'), findsOneWidget);
        expect(find.text('تكبير الصورة'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
