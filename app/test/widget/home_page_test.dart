import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:washij/widgets/hero.dart';

import '../support/test_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeTestCatalog);

  for (final width in [390.0, 820.0, 1280.0]) {
    testWidgets('home page lays out at ${width.toInt()}px', (tester) async {
      setTestViewport(tester, width);
      await openTestRoute(tester, '/');

      expect(find.text('استكشف اللوحات'), findsOneWidget);
      expect(find.text('قصاصة من اللوحة'), findsOneWidget);
      expect(find.byType(HomeHero), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('hero pager stays immediate with reduced motion enabled', (
    tester,
  ) async {
    setTestViewport(tester, 1280);
    tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(
          disableAnimations: true,
          reduceMotion: true,
        );
    addTearDown(
      tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue,
    );
    await openTestRoute(tester, '/');

    final hero = find.byType(HomeHero);
    expect(
      find.descendant(of: hero, matching: find.text('الليلة المرصعة بالنجوم')),
      findsOneWidget,
    );
    final secondPage = find.descendant(of: hero, matching: find.text('02'));
    await tester.ensureVisible(secondPage);
    await tester.tap(secondPage);
    await tester.pump();
    expect(
      find.descendant(
        of: find.byType(HomeHero),
        matching: find.text('الموجة الكبرى قبالة كاناغاوا'),
      ),
      findsOneWidget,
    );
    expect(find.byType(AnimatedSwitcher), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
