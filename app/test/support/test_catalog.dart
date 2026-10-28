import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:washij/app.dart';
import 'package:washij/data/bundled_source.dart';
import 'package:washij/data/catalog.dart';
import 'package:washij/state/providers.dart';
import 'package:washij/widgets/shell.dart';

late Catalog testCatalog;

Future<void> initializeTestCatalog() async {
  testCatalog = await const BundledSource().load();
}

Widget washijTestApp(Catalog catalog, {List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: [
        catalogProvider.overrideWith(() => _StaticCatalogController(catalog)),
        ...overrides,
      ],
      child: const WashijAppRoot(),
    );

void setTestViewport(WidgetTester tester, double width) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 900);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> openTestRoute(WidgetTester tester, String location) async {
  await tester.pumpWidget(washijTestApp(testCatalog));
  await settleMuseum(tester);
  goToRoute(tester, location);
  await settleMuseum(tester);
}

Future<void> settleMuseum(WidgetTester tester) async {
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 5),
  );
}

void goToRoute(WidgetTester tester, String location) {
  final context = tester.element(find.byType(AppShell));
  GoRouter.of(context).go(location);
}

class _StaticCatalogController extends CatalogController {
  _StaticCatalogController(this.catalog);

  final Catalog catalog;

  @override
  Future<Catalog> build() async => catalog;
}
