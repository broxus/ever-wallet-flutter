import 'dart:async';

import 'package:ever_wallet/data/models/search_history_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

class SearchHistoryRepository {
  final HiveSource _hiveSource;
  final _searchHistorySubject = BehaviorSubject<List<SearchHistoryDto>>.seeded([]);

  SearchHistoryRepository(this._hiveSource) {
    _searchHistorySubject.add(_hiveSource.searchHistory);
  }

  Stream<List<SearchHistoryDto>> get searchHistoryStream =>
      _searchHistorySubject.distinct((a, b) => listEquals(a, b));

  List<SearchHistoryDto> get searchHistory => _searchHistorySubject.value;

  Future<void> addSearchHistoryEntry(SearchHistoryDto entry) async {
    if (entry.url.isEmpty) return;

    await _hiveSource.addSearchHistoryEntry(entry);

    _searchHistorySubject.add(_hiveSource.searchHistory);
  }

  Future<void> removeSearchHistoryEntry(SearchHistoryDto entry) async {
    await _hiveSource.removeSearchHistoryEntry(entry);

    _searchHistorySubject.add(_hiveSource.searchHistory);
  }

  Future<void> clear() {
    _searchHistorySubject.add([]);
    return _hiveSource.clearSearchHistory();
  }

  Future<void> dispose() => _searchHistorySubject.close();
}
