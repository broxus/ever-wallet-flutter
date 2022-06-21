import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:rxdart/subjects.dart';

import '../sources/local/hive_source.dart';

@lazySingleton
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
}
