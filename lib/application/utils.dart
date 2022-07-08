import 'package:flutter/widgets.dart';

extension LocaleString on String {
  String toLocaleName() {
    if (this == 'en') return 'English';
    if (this == 'kr') return 'Korean';
    throw UnimplementedError();
  }

  String toLocaleIcon() {
    if (this == 'en') return 'us';
    if (this == 'kr') return 'kr';
    throw UnimplementedError();
  }
}

extension LocaleToStringHelper on Locale {
  String toStringWithSeparator({String separator = '_'}) => toString().split('_').join(separator);
}

extension StringToLocaleHelper on String {
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
}
