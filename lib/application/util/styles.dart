import 'package:ever_wallet/generated/fonts.gen.dart';
import 'package:flutter/material.dart';

/// The palette of text styles in the project
class StylesPalette {
  const StylesPalette({
    required this.basicStyle,
    required this.basicBoldStyle,
    required this.captionStyle,
    required this.appbarStyle,
    required this.header2Style,
    required this.header3Style,
    required this.fullScreenStyle,
    required this.sheetHeaderStyle,
    required this.primaryButtonStyle,
    required this.secondaryButtonStyle,
    required this.sectionCaption,
    required this.subtitleStyle,
  });

  /// Basic texts
  final TextStyle basicStyle;
  final TextStyle basicBoldStyle;
  final TextStyle captionStyle;
  final TextStyle sectionCaption;
  final TextStyle subtitleStyle;

  /// Headers
  final TextStyle appbarStyle;
  final TextStyle header2Style;
  final TextStyle header3Style;
  final TextStyle fullScreenStyle;
  final TextStyle sheetHeaderStyle;

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

  static const subtitleStyle = TextStyle(
    fontSize: 12,
    height: 1.66,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w400,
    fontFamily: FontFamily.pt,
  );

  /// Style for sections in lists
  static const sectionText = TextStyle(
    fontSize: 14,
    height: 1.66,
    letterSpacing: 0.75,
    fontWeight: FontWeight.w700,
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
    fontWeight: FontWeight.w600,
    fontFamily: FontFamily.faktum,
  );

  /// Style for secondary headers
  static const header2Text = TextStyle(
    fontSize: 24,
    height: 1.16,
    letterSpacing: 0.15,
    fontWeight: FontWeight.w400,
    fontFamily: FontFamily.pt,
  );

  /// Style for secondary headers with Faktum font
  static const header2Faktum = TextStyle(
    fontSize: 24,
    height: 1.16,
    fontWeight: FontWeight.w600,
  );

  /// Style for headers under appbar
  static const header3Text = TextStyle(
    fontSize: 24,
    height: 1.33,
    fontWeight: FontWeight.w700,
    fontFamily: FontFamily.pt,
  );

  static const header3Faktum = TextStyle(
    fontSize: 18,
    height: 1.33,
    fontWeight: FontWeight.w600,
    fontFamily: FontFamily.faktum,
    letterSpacing: 0.1,
  );

  static const bold18Body = TextStyle(
    fontSize: 18,
    height: 1.33,
    fontWeight: FontWeight.w700,
    fontFamily: FontFamily.pt,
    letterSpacing: 0.5,
  );
  static const medium14Caption = TextStyle(
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w500,
    fontFamily: FontFamily.pt,
    letterSpacing: 0.75,
  );

  /// Style for header in bottom sheet
  static const sheetHeaderText = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 28,
    height: 1.21,
    fontFamily: FontFamily.pt,
  );

  /// Biggest text for some titles on screen
  static const fullscreenText = TextStyle(
    fontSize: 54,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w700,
    fontFamily: FontFamily.pt,
  );

  static const bold20 = TextStyle(
    fontSize: 20,
    letterSpacing: 0.15,
    fontWeight: FontWeight.w700,
    fontFamily: FontFamily.pt,
    height: 1.2,
  );

  static const regular14 = TextStyle(
    fontSize: 14,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w400,
    fontFamily: FontFamily.pt,
    height: 1.42,
  );

  static const regular16 = TextStyle(
    fontSize: 16,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w400,
    fontFamily: FontFamily.pt,
    height: 1.375,
  );
}
