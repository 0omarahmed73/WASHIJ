import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

final washijTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  scaffoldBackgroundColor: WashijColors.midnight,
  fontFamily: WashijFonts.ui,
  fontFamilyFallback: const [WashijFonts.cjkFallback],
  colorScheme: const ColorScheme.dark(
    primary: WashijColors.cobalt,
    onPrimary: WashijColors.ivory,
    secondary: WashijColors.starYellow,
    onSecondary: WashijColors.midnight,
    surface: WashijColors.deepBlue,
    onSurface: WashijColors.ivory,
    error: WashijColors.danger,
    onError: WashijColors.midnight,
  ),
  textTheme: WashijTypography.textTheme.apply(
    bodyColor: WashijColors.ivory,
    displayColor: WashijColors.ivory,
    fontFamilyFallback: const [WashijFonts.cjkFallback],
  ),
  dividerColor: WashijColors.hairline,
  focusColor: WashijColors.starYellow,
  splashColor: WashijColors.starYellow.withValues(alpha: 0.12),
  highlightColor: WashijColors.starYellow.withValues(alpha: 0.08),
  appBarTheme: const AppBarTheme(
    backgroundColor: WashijColors.midnight,
    foregroundColor: WashijColors.ivory,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
  ),
  cardTheme: const CardThemeData(
    color: WashijColors.deepBlue,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: WashijColors.hairline),
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: WashijColors.hairline,
    thickness: 1,
    space: 1,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: WashijColors.nightRaised,
    labelStyle: const TextStyle(color: WashijColors.mist),
    hintStyle: const TextStyle(color: WashijColors.mist),
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: WashijColors.borderControl),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: WashijColors.borderControl),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: WashijColors.starYellow, width: 2),
    ),
    errorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: WashijColors.danger),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: WashijColors.starYellow, width: 2),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style:
        OutlinedButton.styleFrom(
          foregroundColor: WashijColors.ivory,
          side: const BorderSide(color: WashijColors.borderControl),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          minimumSize: const Size(44, 44),
        ).copyWith(
          side: washijFocusSide(
            const BorderSide(color: WashijColors.borderControl),
          ),
        ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: WashijColors.mutedSky,
      minimumSize: const Size(44, 44),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ).copyWith(side: washijFocusSide(BorderSide.none)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: WashijColors.cobalt,
      foregroundColor: WashijColors.ivory,
      minimumSize: const Size(44, 44),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ).copyWith(side: washijFocusSide(BorderSide.none)),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: WashijColors.cobalt,
      foregroundColor: WashijColors.ivory,
      minimumSize: const Size(44, 44),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ).copyWith(side: washijFocusSide(BorderSide.none)),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ).copyWith(side: washijFocusSide(BorderSide.none)),
  ),
  iconTheme: const IconThemeData(color: WashijColors.ivory),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: WashijColors.starYellow,
    selectionColor: Color(0x66F2C94C),
    selectionHandleColor: WashijColors.starYellow,
  ),
);
