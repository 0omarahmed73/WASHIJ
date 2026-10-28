import 'package:flutter/material.dart';

abstract final class WashijFonts {
  static const heading = 'ArefRuqaa';
  static const reading = 'ScheherazadeNew';
  static const ui = 'ReadexPro';
  static const englishDisplay = 'CormorantGaramond';
  static const wordmark = 'Amiri';
  static const cjkFallback = 'WashijCjkFallback';
}

abstract final class WashijTypography {
  static const textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: WashijFonts.heading,
      fontSize: 56,
      height: 1.2,
      fontWeight: FontWeight.w700,
    ),
    displayMedium: TextStyle(
      fontFamily: WashijFonts.heading,
      fontSize: 44,
      height: 1.25,
      fontWeight: FontWeight.w700,
    ),
    headlineLarge: TextStyle(
      fontFamily: WashijFonts.heading,
      fontSize: 36,
      height: 1.3,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: TextStyle(
      fontFamily: WashijFonts.heading,
      fontSize: 30,
      height: 1.35,
      fontWeight: FontWeight.w700,
    ),
    titleLarge: TextStyle(
      fontFamily: WashijFonts.heading,
      fontSize: 24,
      height: 1.4,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: TextStyle(
      fontFamily: WashijFonts.ui,
      fontSize: 18,
      height: 1.5,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      fontFamily: WashijFonts.reading,
      fontSize: 22,
      height: 1.8,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      fontFamily: WashijFonts.reading,
      fontSize: 19,
      height: 1.8,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      fontFamily: WashijFonts.ui,
      fontSize: 13,
      height: 1.55,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: TextStyle(
      fontFamily: WashijFonts.ui,
      fontSize: 15,
      height: 1.5,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: TextStyle(
      fontFamily: WashijFonts.ui,
      fontSize: 13,
      height: 1.5,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      fontFamily: WashijFonts.ui,
      fontSize: 12,
      height: 1.5,
      fontWeight: FontWeight.w500,
    ),
  );

  static const englishDisplay = TextStyle(
    fontFamily: WashijFonts.englishDisplay,
    fontSize: 30,
    height: 1.1,
    fontWeight: FontWeight.w500,
    letterSpacing: 9.6,
  );
}
