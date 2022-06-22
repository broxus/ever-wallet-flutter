import 'package:flutter/material.dart';

import '../../generated/fonts.gen.dart';

/// The palette of text styles in the project
class StylesPalette {
  const StylesPalette({
    required this.basicStyle,
    required this.captionStyle,
    required this.appbarStyle,
    required this.header2Style,
    required this.fullScreenStyle,
    required this.primaryButtonStyle,
    required this.secondaryButtonStyle,
  });

  /// Basic texts
  final TextStyle basicStyle;
  final TextStyle captionStyle;

  /// Headers
  final TextStyle appbarStyle;
  final TextStyle header2Style;
  final TextStyle fullScreenStyle;

  /// Buttons
  final TextStyle primaryButtonStyle;
  final TextStyle secondaryButtonStyle;
}

class StylesRes {
  const StylesRes._();

  /// Basic text that displays information on the screen
  static const basicText = TextStyle(
    fontSize: 16,
    height: 1.375,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w400,
    fontFamily: FontFamily.pt,
  );

  /// Style for captions
  static const captionText = TextStyle(
    fontSize: 14,
    height: 1.42,
    letterSpacing: 0.75,
    fontWeight: FontWeight.w400,
    fontFamily: FontFamily.pt,
  );

  /// Style for basic buttons
  static const buttonText = TextStyle(
    fontSize: 16,
    height: 1.25,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w700,
    fontFamily: FontFamily.pt,
  );

  /// Style for appbars
  static const headerText = TextStyle(
    fontSize: 34,
    height: 1.176,
    fontWeight: FontWeight.w700,
    fontFamily: FontFamily.pt,
  );

  /// Style for secondary headers
  static const header2Text = TextStyle(
    fontSize: 24,
    height: 1.16,
    letterSpacing: 0.15,
    fontWeight: FontWeight.w400,
    fontFamily: FontFamily.pt,
  );

  /// Biggest text for some titles on screen
  static const fullscreenText = TextStyle(
    fontSize: 54,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w700,
    fontFamily: FontFamily.pt,
  );
}
