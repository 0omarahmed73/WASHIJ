import 'package:flutter_test/flutter_test.dart';

import '../support/test_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeTestCatalog);

  for (final width in [390.0, 820.0, 1280.0]) {
    testWidgets('artist and movement pages render at ${width.toInt()}px', (
      tester,
    ) async {
      setTestViewport(tester, width);
      await openTestRoute(tester, '/');
      goToRoute(tester, '/artists');
      await settleMuseum(tester);
      expect(find.text('الفنانون'), findsWidgets);

      goToRoute(tester, '/artist/van-gogh');
      await settleMuseum(tester);
      expect(find.text(testCatalog.artists['van-gogh']!.nameAr), findsWidgets);
      expect(find.text('أعمال الفنان'), findsOneWidget);

      goToRoute(tester, '/movements');
      await settleMuseum(tester);
      expect(find.text('المدارس الفنية'), findsWidgets);

      goToRoute(tester, '/movement/renaissance');
      await settleMuseum(tester);
      expect(
        find.text(testCatalog.movements['renaissance']!.nameAr),
        findsWidgets,
      );
      expect(find.text('أعمال من المدرسة'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('unknown artist and movement ids are handled', (tester) async {
    await openTestRoute(tester, '/');
    goToRoute(tester, '/artist/not-an-artist');
    await settleMuseum(tester);
    expect(find.text('لم نعثر على الفنان المطلوب.'), findsOneWidget);

    goToRoute(tester, '/movement/not-a-movement');
    await settleMuseum(tester);
    expect(find.text('لم نعثر على المدرسة الفنية المطلوبة.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
