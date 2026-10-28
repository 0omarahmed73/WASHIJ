import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:washij/theme/theme.dart';
import 'package:washij/theme/tokens.dart';
import 'package:washij/widgets/focus_ring.dart';

void main() {
  test('all button themes resolve to a 2px yellow focus border', () {
    final styles = [
      washijTheme.outlinedButtonTheme.style!,
      washijTheme.textButtonTheme.style!,
      washijTheme.elevatedButtonTheme.style!,
      washijTheme.filledButtonTheme.style!,
      washijTheme.iconButtonTheme.style!,
    ];

    for (final style in styles) {
      final side = style.side!.resolve({WidgetState.focused})!;
      expect(side.color, WashijColors.starYellow);
      expect(side.width, 2);
    }
  });

  test('focused error fields retain the yellow focus ring', () {
    final border = washijTheme.inputDecorationTheme.focusedErrorBorder!;

    expect(border.borderSide.color, WashijColors.starYellow);
    expect(border.borderSide.width, 2);
  });

  testWidgets('custom tappable surfaces show the ring while focused', (
    tester,
  ) async {
    final focusNode = FocusNode();
    final outsideFocusNode = FocusNode();
    addTearDown(focusNode.dispose);
    addTearDown(outsideFocusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: washijTheme,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FocusRing(
                  child: Material(
                    color: WashijColors.deepBlue,
                    child: InkWell(
                      focusNode: focusNode,
                      onTap: () {},
                      child: const SizedBox(
                        width: 180,
                        height: 48,
                        child: Center(child: Text('اختبار')),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  focusNode: outsideFocusNode,
                  onTap: () {},
                  child: const SizedBox(width: 180, height: 48),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('washij-focus-ring')), findsNothing);
    focusNode.requestFocus();
    await tester.pump();
    expect(find.byKey(const ValueKey('washij-focus-ring')), findsOneWidget);

    outsideFocusNode.requestFocus();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('washij-focus-ring')), findsNothing);
  });
}
