import 'dart:async';

import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';

class LocaleRepository {
  final HiveSource _hiveSource;

  LocaleRepository(this._hiveSource);

  Stream<String?> get localeStream => _hiveSource.localeStream;

  String? get locale => _hiveSource.locale;

  Future<void> setLocale(String locale) => _hiveSource.setLocale(locale);

  Future<void> clear() => _hiveSource.clearLocale();
}
