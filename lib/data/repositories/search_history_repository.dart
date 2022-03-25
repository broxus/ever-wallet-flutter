import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../sources/local/hive_source.dart';

@preResolve
@lazySingleton
class SearchHistoryRepository {
  final HiveSource _hiveSource;
  final _searchHistorySubject = BehaviorSubject<List<String>>.seeded([]);

  SearchHistoryRepository._(this._hiveSource);

  @factoryMethod
  static Future<SearchHistoryRepository> create({
    required HiveSource hiveSource,
  }) async {
    final instance = SearchHistoryRepository._(hiveSource);
    await instance._initialize();
    return instance;
  }

  Stream<List<String>> get searchHistoryStream => _searchHistorySubject.distinct((a, b) => listEquals(a, b));

  List<String> get searchHistory => _searchHistorySubject.value;

  Future<void> addSearchHistoryEntry(String entry) async {
    if (entry.isEmpty) return;

    await _hiveSource.addSearchHistoryEntry(entry);

    _searchHistorySubject.add(_hiveSource.searchHistory);
  }

  Future<void> removeSearchHistoryEntry(String entry) async {
    await _hiveSource.removeSearchHistoryEntry(entry);

    _searchHistorySubject.add(_hiveSource.searchHistory);
  }

  Future<void> clear() => _hiveSource.clearSearchHistory();

  Future<void> _initialize() async {
    _searchHistorySubject.add(_hiveSource.searchHistory);
  }
}
