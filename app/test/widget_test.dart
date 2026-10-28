import 'package:flutter_test/flutter_test.dart';

import 'support/test_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeTestCatalog);

  testWidgets('WASHIJ starts with the Arabic museum shell', (tester) async {
    await tester.pumpWidget(washijTestApp(testCatalog));
    await tester.pumpAndSettle();

    expect(find.textContaining('كل لوحة خيط'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
