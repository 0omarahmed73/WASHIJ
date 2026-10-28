import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:washij/widgets/artwork_card.dart';
import 'package:washij/widgets/shell.dart';

import '../support/test_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeTestCatalog);

  testWidgets('in-app links and router back follow real route paths', (
    tester,
  ) async {
    setTestViewport(tester, 1280);
    await openTestRoute(tester, '/');
    await tester.tap(find.text('استكشف اللوحات'));
    await settleMuseum(tester);
    expect(find.text('في المجموعة'), findsOneWidget);

    await tester.tap(find.byType(ArtworkCard).first);
    await settleMuseum(tester);
    final context = tester.element(find.byType(AppShell));
    final router = GoRouter.of(context);
    expect(router.state.uri.path, startsWith('/artwork/'));

    unawaited(router.push('/artists'));
    await settleMuseum(tester);
    expect(router.state.uri.path, '/artists');

    router.pop();
    await settleMuseum(tester);
    expect(router.state.uri.path, startsWith('/artwork/'));
    expect(tester.takeException(), isNull);
  });
}
