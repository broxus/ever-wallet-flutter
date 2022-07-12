import 'package:ever_wallet/application/util/theme_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension ContextExtension on BuildContext {
  AppLocalizations get localization {
    return AppLocalizations.of(this)!;
  }

  ThemeStyle get themeStyle {
    return Theme.of(this).extension<ThemeStyle>()!;
  }
}
