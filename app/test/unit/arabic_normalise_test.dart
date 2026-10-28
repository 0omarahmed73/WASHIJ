import 'package:flutter_test/flutter_test.dart';
import 'package:washij/data/arabic_normalise.dart';

void main() {
  group('normaliseSearchText', () {
    test('strips Arabic diacritics and tatweel', () {
      expect(
        normaliseSearchText('اللَّيْلَة ـ المُرَصَّعَة'),
        'الليله المرصعه',
      );
    });

    test('unifies alef, ya, and ta marbuta forms', () {
      expect(normaliseSearchText('آية هدى'), 'ايه هدي');
    });

    test('normalises hamza carriers', () {
      expect(normaliseSearchText('مؤمن، بيئة'), 'مومن، بييه');
    });

    test('matches Latin names case-insensitively', () {
      expect(normaliseSearchText('Vincent VAN Gogh'), 'vincent van gogh');
    });

    test('collapses and trims whitespace', () {
      expect(normaliseSearchText('  Starry\t\nNight  '), 'starry night');
    });
  });
}
