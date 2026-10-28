import 'package:flutter/material.dart';

abstract final class WashijColors {
  static const midnight = Color(0xFF081B33);
  static const deepBlue = Color(0xFF0E2542);
  static const nightRaised = Color(0xFF14305A);
  static const indigo = Color(0xFF1E3A8A);
  static const cobalt = Color(0xFF2563EB);
  static const mutedSky = Color(0xFF7DA3D8);
  static const mist = Color(0xFF9FB3CF);
  static const ivory = Color(0xFFF6F2E9);
  static const starYellow = Color(0xFFF2C94C);
  static const hairline = Color(0xFF1F3A5F);
  static const borderControl = Color(0xFF5E7CA6);
  static const danger = Color(0xFFE8907A);
}

WidgetStateBorderSide washijFocusSide(BorderSide restingSide) =>
    WidgetStateBorderSide.resolveWith(
      (states) => states.contains(WidgetState.focused)
          ? const BorderSide(color: WashijColors.starYellow, width: 2)
          : restingSide,
    );
