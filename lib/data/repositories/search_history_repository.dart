import 'dart:async';

import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

class SearchHistoryRepository {
  final HiveSource _hiveSource;
  final _searchHistorySubject = BehaviorSubject<List<String>>.seeded([]);

  SearchHistoryRepository(this._hiveSource) {
    _searchHistorySubject.add(_hiveSource.searchHistory);
  }

  Stream<List<String>> get searchHistoryStream =>
      _searchHistorySubject.distinct((a, b) => listEquals(a, b));

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

  Future<void> dispose() => _searchHistorySubject.close();
}
