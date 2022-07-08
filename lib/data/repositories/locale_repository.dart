import 'dart:async';

import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:rxdart/subjects.dart';

class LocaleRepository {
  final HiveSource _hiveSource;
  final _localeSubject = BehaviorSubject<String?>();

  LocaleRepository(this._hiveSource) {
    _localeSubject.add(_hiveSource.locale);
  }

  Stream<String?> get localeStream => _localeSubject.distinct();

  String? get locale => _localeSubject.valueOrNull;

  Future<void> setLocale(String locale) {
    _localeSubject.add(locale);
    return _hiveSource.setLocale(locale);
  }

  Future<void> dispose() => _localeSubject.close();
}
