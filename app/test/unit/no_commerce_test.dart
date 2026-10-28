import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('product source and editorial data contain no commerce language', () {
    final files = [
      ...Directory('lib').listSync(recursive: true).whereType<File>(),
      ...Directory('assets/data').listSync(recursive: true).whereType<File>(),
    ];
    final prohibited = [
      RegExp(r'\bprices?\b', caseSensitive: false),
      RegExp(r'\bcarts?\b', caseSensitive: false),
      RegExp(r'\bbids?(?:ding)?\b|\bauctions?\b', caseSensitive: false),
      RegExp(r'\bpurchases?\b|\bbuys?\b|\bsells?\b', caseSensitive: false),
      RegExp(
        r'(?<![\p{L}])(?:سعر|أسعار|شراء|اشتر[\p{L}]*|بيع|مزايدة|مزاد|عربة|تداول)(?![\p{L}])',
        unicode: true,
      ),
    ];

    for (final file in files) {
      final source = file.readAsStringSync();
      for (final pattern in prohibited) {
        expect(
          pattern.hasMatch(source),
          isFalse,
          reason: '${file.path} contains prohibited commerce language.',
        );
      }
    }
  });
}
