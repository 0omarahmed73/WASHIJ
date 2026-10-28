import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:washij/pages/artwork_page.dart';
import 'package:washij/widgets/mat.dart';

import '../support/test_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeTestCatalog);

  for (final width in [390.0, 820.0, 1280.0]) {
    testWidgets('artwork page and credit render at ${width.toInt()}px', (
      tester,
    ) async {
      setTestViewport(tester, width);
      await openTestRoute(tester, '/artwork/starry-night');

      expect(find.text('الليلة المرصعة بالنجوم'), findsWidgets);
      await tester.drag(
        find.byType(CustomScrollView).first,
        const Offset(0, -2500),
      );
      await settleMuseum(tester);
      expect(find.textContaining('اعتماد الصورة:'), findsOneWidget);
      expect(find.text('حكاية اللوحة'), findsWidgets);
      expect(find.text('قراءة فنية'), findsWidgets);
      expect(find.text('تفسيرات منسوبة'), findsWidgets);
      expect(find.text('لوحات متصلة'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('withheld painting displays no image in its mat', (tester) async {
    await openTestRoute(tester, '/artwork/persistence-of-memory');

    expect(
      tester.widget<ArtworkPage>(find.byType(ArtworkPage)).id,
      'persistence-of-memory',
    );
    expect(find.text('إصرار الذاكرة'), findsWidgets);
    expect(find.text('الصورة غير معروضة لأن حقوقها محفوظة'), findsOneWidget);
    final mainMat = find
        .descendant(
          of: find.byType(ArtworkPage),
          matching: find.byType(ArtworkMat),
        )
        .first;
    expect(
      find.descendant(of: mainMat, matching: find.byType(Image)),
      findsNothing,
    );
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -2500),
    );
    await settleMuseum(tester);
    expect(find.textContaining('CC BY-SA'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unknown artwork id gives a not-found page', (tester) async {
    await openTestRoute(tester, '/artwork/not-a-work');
    expect(find.text('لم نعثر على هذه اللوحة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
