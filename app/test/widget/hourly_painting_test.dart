import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:washij/widgets/hourly_painting.dart';
import 'package:washij/widgets/shell.dart';

import '../support/test_catalog.dart';

/// Asset loading needs real async time under the widget-test fake clock.
/// Scrolls the hourly painting into view and waits for its data to load.
Future<void> showHourlyPainting(WidgetTester tester) async {
  // The app's start-up splash overlay blocks taps for the first 3.3 seconds.
  await tester.pump(const Duration(seconds: 4));
  // The home page builds its sections lazily, so the data only starts
  // loading once the section is scrolled into view.
  for (var i = 0; i < 50; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    if (find.text('افتح اللوحة').evaluate().isNotEmpty) break;
  }
  await settleMuseum(tester);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeTestCatalog);

  for (final width in [390.0, 820.0, 1280.0]) {
    testWidgets('hourly painting lays out at ${width.toInt()}px', (
      tester,
    ) async {
      setTestViewport(tester, width);
      await openTestRoute(tester, '/');
      await showHourlyPainting(tester);
      await settleMuseum(tester);

      expect(find.text('لوحة هذه الساعة'), findsOneWidget);
      expect(find.text('لوحة أخرى'), findsOneWidget);
      expect(find.text('افتح اللوحة'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('refresh changes the painting and tapping opens it in the app', (
    tester,
  ) async {
    setTestViewport(tester, 1280);
    await openTestRoute(tester, '/');
    await showHourlyPainting(tester);
    await settleMuseum(tester);

    String shown() => tester
        .widget<Semantics>(
          find
              .descendant(
                of: find.byType(HourlyPainting),
                matching: find.byWidgetPredicate(
                  (widget) =>
                      widget is Semantics &&
                      (widget.properties.label ?? '').startsWith(
                        'لوحة هذه الساعة:',
                      ),
                ),
              )
              .first,
        )
        .properties
        .label!;

    final before = shown();
    await tester.tap(find.text('لوحة أخرى'));
    await settleMuseum(tester);
    expect(shown(), isNot(before));

    await tester.tap(find.text('افتح اللوحة'));
    await settleMuseum(tester);
    final location = GoRouter.of(tester.element(find.byType(AppShell)))
        .state
        .uri
        .path;
    expect(location, startsWith('/artwork/museum/'));
  });
}
