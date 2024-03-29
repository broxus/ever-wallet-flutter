import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:flutter/material.dart';

final darkStyle = ThemeStyle(
  colors: const ColorsPalette(
    primaryBackgroundColor: ColorsRes.black,
    secondaryBackgroundColor: ColorsRes.white,
    thirdBackgroundColor: ColorsRes.darkBlue,
    fourthBackgroundColor: ColorsRes.greyOpacity,
    primaryTextColor: ColorsRes.white,
    primaryButtonTextColor: ColorsRes.text,
    secondaryButtonTextColor: ColorsRes.lightBlue,
    primaryButtonColor: ColorsRes.lightBlue,
    secondaryButtonColor: ColorsRes.buttonOpacity,
    thirdButtonColor: ColorsRes.greenOpacity,
    textPrimaryTextButtonColor: ColorsRes.darkBlue,
    textSecondaryTextButtonColor: ColorsRes.grey,
    iconPrimaryButtonColor: ColorsRes.darkBlue,
    iconSecondaryButtonColor: ColorsRes.greyBlue,
    activeInputColor: ColorsRes.lightBlueOpacity,
    inactiveInputColor: ColorsRes.whiteOpacityLight,
    primaryPressStateColor: ColorsRes.whiteOpacity,
    secondaryPressStateColor: ColorsRes.neutral750,
    errorTextColor: ColorsRes.redLight,
    errorInputColor: ColorsRes.redLight,
  ),
  styles: StylesPalette(
    primaryButtonStyle: StylesRes.buttonText.copyWith(color: ColorsRes.text),
    secondaryButtonStyle: StylesRes.buttonText.copyWith(color: ColorsRes.lightBlue),
    appbarStyle: StylesRes.headerText.copyWith(color: ColorsRes.white),
    basicStyle: StylesRes.basicText.copyWith(color: ColorsRes.white),
    basicBoldStyle: StylesRes.basicText.copyWith(
      color: ColorsRes.lightBlue,
      fontWeight: FontWeight.w700,
    ),
    header2Style: StylesRes.header2Text.copyWith(color: ColorsRes.white),
    header3Style: StylesRes.header3Text.copyWith(color: ColorsRes.text),
    sheetHeaderStyle: StylesRes.sheetHeaderText.copyWith(color: ColorsRes.text),
    captionStyle: StylesRes.captionText.copyWith(color: ColorsRes.lightBlue),
    fullScreenStyle: StylesRes.fullscreenText.copyWith(color: ColorsRes.white),
    sectionCaption: StylesRes.sectionText.copyWith(color: ColorsRes.grey),
    subtitleStyle: StylesRes.subtitleStyle.copyWith(color: ColorsRes.grey),
  ),
);

/// TODO: Change colors after design update
final lightStyle = ThemeStyle(
  colors: const ColorsPalette(
    primaryBackgroundColor: ColorsRes.black,
    secondaryBackgroundColor: ColorsRes.white,
    thirdBackgroundColor: ColorsRes.darkBlue,
    fourthBackgroundColor: ColorsRes.greyOpacity,
    primaryTextColor: ColorsRes.white,
    primaryButtonTextColor: ColorsRes.text,
    secondaryButtonTextColor: ColorsRes.lightBlue,
    primaryButtonColor: ColorsRes.lightBlue,
    secondaryButtonColor: ColorsRes.buttonOpacity,
    thirdButtonColor: ColorsRes.greenOpacity,
    textPrimaryTextButtonColor: ColorsRes.darkBlue,
    textSecondaryTextButtonColor: ColorsRes.grey,
    iconPrimaryButtonColor: ColorsRes.darkBlue,
    iconSecondaryButtonColor: ColorsRes.greyBlue,
    activeInputColor: ColorsRes.lightBlueOpacity,
    inactiveInputColor: ColorsRes.whiteOpacityLight,
    primaryPressStateColor: ColorsRes.whiteOpacity,
    secondaryPressStateColor: ColorsRes.neutral750,
    errorTextColor: ColorsRes.redLight,
    errorInputColor: ColorsRes.redLight,
  ),
  styles: StylesPalette(
    primaryButtonStyle: StylesRes.buttonText.copyWith(color: ColorsRes.text),
    secondaryButtonStyle: StylesRes.buttonText.copyWith(color: ColorsRes.lightBlue),
    appbarStyle: StylesRes.headerText.copyWith(color: ColorsRes.white),
    basicStyle: StylesRes.basicText.copyWith(color: ColorsRes.white),
    basicBoldStyle: StylesRes.basicText.copyWith(
      color: ColorsRes.lightBlue,
      fontWeight: FontWeight.w700,
    ),
    header2Style: StylesRes.header2Text.copyWith(color: ColorsRes.white),
    header3Style: StylesRes.header3Text.copyWith(color: ColorsRes.text),
    sheetHeaderStyle: StylesRes.sheetHeaderText.copyWith(color: ColorsRes.text),
    captionStyle: StylesRes.captionText.copyWith(color: ColorsRes.lightBlue),
    fullScreenStyle: StylesRes.fullscreenText.copyWith(color: ColorsRes.white),
    sectionCaption: StylesRes.sectionText.copyWith(color: ColorsRes.grey),
    subtitleStyle: StylesRes.subtitleStyle.copyWith(color: ColorsRes.grey),
  ),
);

class ThemeStyle extends ThemeExtension<ThemeStyle> {
  ThemeStyle({
    required this.colors,
    required this.styles,
  });

  final ColorsPalette colors;
  final StylesPalette styles;

  /// Do not supported
  @override
  ThemeExtension<ThemeStyle> copyWith() => this;

  /// Do not supported
  @override
  ThemeExtension<ThemeStyle> lerp(ThemeExtension<ThemeStyle>? other, double t) => this;
}
