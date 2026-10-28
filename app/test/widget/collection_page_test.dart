import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeTestCatalog);

  for (final width in [390.0, 820.0, 1280.0]) {
    testWidgets('collection lays out at ${width.toInt()}px', (tester) async {
      setTestViewport(tester, width);
      await openTestRoute(tester, '/artworks');

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('14 لوحة'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('collection search, no-results and load-more work', (
    tester,
  ) async {
    setTestViewport(tester, 1280);
    await openTestRoute(tester, '/artworks?q=starry');

    expect(find.text('1 لوحة'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'no-such-artwork');
    await settleMuseum(tester);
    expect(find.text('لم نجد لوحات تطابق هذا البحث'), findsOneWidget);

    await tester.tap(find.text('مسح المرشحات').first);
    await settleMuseum(tester);
    expect(find.text('14 لوحة'), findsOneWidget);
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -1000),
    );
    await settleMuseum(tester);
    await tester.tap(find.text('تحميل المزيد من اللوحات'));
    await settleMuseum(tester);
    expect(find.text('14 لوحة'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'after first load-more');
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -1000),
    );
    await settleMuseum(tester);
    await tester.tap(find.text('تحميل المزيد من اللوحات'));
    await settleMuseum(tester);
    expect(find.text('تحميل المزيد من اللوحات'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
