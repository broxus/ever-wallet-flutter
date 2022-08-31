import 'package:flutter/widgets.dart';

extension LocaleString on String {
  String toLocaleName() {
    if (this == 'en') return 'English';
    if (this == 'ko') return 'Korean';
    if (this == 'ja') return 'Japanese';
    throw UnimplementedError();
  }

  String toLocaleIcon() {
    if (this == 'en') return 'us';
    if (this == 'ko') return 'kr';
    if (this == 'ja') return 'jp';
    throw UnimplementedError();
  }

  Locale toLocale({String separator = '_'}) {
    final localeList = split(separator);
    switch (localeList.length) {
      case 2:
        return Locale(localeList.first, localeList.last);
      case 3:
        return Locale.fromSubtags(
          languageCode: localeList.first,
          scriptCode: localeList[1],
          countryCode: localeList.last,
        );
      default:
        return Locale(localeList.first);
    }
  }

  /// For [TextOverflow.ellipsis] for better displaying with ellipsis
  ///
  /// \u{200B} adds an unbreakable gap
  /// {issue for this https://github.com/flutter/flutter/issues/18761}
  String get overflow => characters.replaceAll(Characters(''), Characters('\u{200B}')).string;
}

extension LocaleToStringHelper on Locale {
  String toStringWithSeparator({String separator = '_'}) => toString().split('_').join(separator);
}
