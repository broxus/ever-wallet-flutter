import 'package:flutter/material.dart';

/// The palette of colors in the project
/// !!! Right now names of colors are approximate, it will be changed after creating of design system
class ColorsPalette {
  const ColorsPalette({
    required this.primaryBackgroundColor,
    required this.secondaryBackgroundColor,
    required this.thirdBackgroundColor,
    required this.fourthBackgroundColor,
    required this.primaryTextColor,
    required this.primaryButtonTextColor,
    required this.secondaryButtonTextColor,
    required this.primaryButtonColor,
    required this.secondaryButtonColor,
    required this.thirdButtonColor,
    required this.textPrimaryTextButtonColor,
    required this.textSecondaryTextButtonColor,
    required this.iconPrimaryButtonColor,
    required this.iconSecondaryButtonColor,
    required this.activeInputColor,
    required this.inactiveInputColor,
    required this.primaryPressStateColor,
    required this.secondaryPressStateColor,
  });

  /// Colors for backgrounds
  final Color primaryBackgroundColor;
  final Color secondaryBackgroundColor;
  final Color thirdBackgroundColor;
  final Color fourthBackgroundColor;

  /// Colors for basic text
  final Color primaryTextColor;

  /// Colors for main button texts
  final Color primaryButtonTextColor;
  final Color secondaryButtonTextColor;

  /// Colors of default buttons
  final Color primaryButtonColor;
  final Color secondaryButtonColor;
  final Color thirdButtonColor;

  /// Colors of text of text buttons
  final Color textPrimaryTextButtonColor;
  final Color textSecondaryTextButtonColor;

  /// Colors for all icon based button
  final Color iconPrimaryButtonColor;
  final Color iconSecondaryButtonColor;

  /// Colors for inputs, checkboxes
  final Color activeInputColor;
  final Color inactiveInputColor;

  /// Color when pressing button
  final Color primaryPressStateColor;
  final Color secondaryPressStateColor;
}

/// Color design system
class ColorsRes {
  const ColorsRes._();

  static const darkBlue = Color(0xFF0088CC);
  static const lightBlue = Color(0xFFC5E4F3);
  static const lightBlueOpacity = Color(0xA3C5E4F3);
  static const white = Colors.white;
  static const whiteOpacity = Color(0x8FFFFFFF);
  static const whiteOpacityLight = Color(0x66FFFFFF);
  static const black = Color(0xFF060C32);
  static const text = Color(0xFF050A2E);
  static const buttonOpacity = Color(0x29C5E4F3);
  static const greenOpacity = Color(0x524AB44A);
  static const grey = Color(0xFF96A1A7);
  static const greyOpacity = Color(0xE0F8F8FB);
  static const greyBlue = Color(0xFF838699);
  static const redDark = Color(0xFFD70000);
}
