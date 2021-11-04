import 'package:flutter/material.dart';

import '../../generated/fonts.gen.dart';

final applicationTheme = ThemeData(
  appBarTheme: const AppBarTheme(
    brightness: Brightness.dark,
    color: CrystalColor.background,
    elevation: 0,
  ),
  fontFamily: FontFamily.pt,
  brightness: Brightness.dark,
  primaryColorBrightness: Brightness.dark,
  primaryColor: CrystalColor.primary,
  accentColor: CrystalColor.accent,
  errorColor: CrystalColor.error,
  dividerColor: CrystalColor.divider,
  shadowColor: CrystalColor.shadow,
  scaffoldBackgroundColor: CrystalColor.primary,
  hintColor: CrystalColor.fontSecondaryDark,
  buttonColor: CrystalColor.accent,
  iconTheme: const IconThemeData(
    color: CrystalColor.icon,
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: CrystalColor.cursorColor,
    selectionColor: CrystalColor.hintColor,
  ),
);

abstract class CrystalColor {
  static const primary = Color(0xFFFFFFFF);

  static const iosBackground = Color(0xFFF2F2F7);

  static const background = Color(0xFF060C32);
  static const accentBackground = Color(0xFFFCF6F3);
  static const secondaryBackground = Color.fromRGBO(197, 228, 243, 0.16);
  static const grayBackground = Color(0xFFF8F9F9);
  static const whitelight = Color(0xFFF5F5F5);
  static const iconBackground = Color(0xFFF2F3F6);
  static const actionBackground = Color(0xFF0F174B);

  static const success = Color(0xFF00AC47);
  static const error = Color(0xFFCC0022);
  static const pending = Color(0xFFE6AC00);

  static const accent = Color(0xFF0088CC);
  static const secondary = Color(0xFFC5E4F3);

  static const fontLight = Color(0xFFFFFFFF);

  static const fontSecondaryLight = Color(0xFFC5E4F3);

  static const fontDark = Color(0xFF000000);

  static const fontSecondaryDark = Color(0xFF96A1A7);
  static const fontTitleSecondaryDark = Color(0xFF7D8B92);

  static const chipText = Color(0xFF364046);
  static const chipColor = Color(0xFFEBEDEE);

  static const cursorColor = Color(0xFF000000);
  static const hintColor = Color(0xFF96A1A7);

  static const border = Color(0xFFDDE1E2);
  static const divider = Color(0xFFEBEDEE);
  static const shadow = Color.fromRGBO(43, 51, 56, 0.08);
  static const modalBackground = Color.fromRGBO(0, 0, 0, 0.4);
  static const navigationBarBackground = Color.fromRGBO(249, 249, 249, 0.96);

  static const icon = Color(0xFFCED3D6);

  static const fontHeaderDark = Color(0xFF293166);

  static const badge = Color(0xFFE80B2F);

  static const shimmerBackground = Color.fromRGBO(255, 255, 255, 0.12);
  static const shimmerHighlight = Color.fromRGBO(255, 255, 255, 0.32);
}
