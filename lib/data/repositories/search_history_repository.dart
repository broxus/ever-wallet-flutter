import 'dart:async';

import 'package:ever_wallet/data/models/search_history_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';

class SearchHistoryRepository {
  final HiveSource _hiveSource;

  SearchHistoryRepository(this._hiveSource);

  Stream<List<String>> get searchHistoryStream => _hiveSource.searchHistoryStream;

  List<String> get searchHistory => _hiveSource.searchHistory;

  Future<void> addSearchHistoryEntry(SearchHistoryDto entry) async {
    if (entry.url.isEmpty) return;

    await _hiveSource.addSearchHistoryEntry(entry);
  }

  Future<void> removeSearchHistoryEntry(SearchHistoryDto entry) =>
      _hiveSource.removeSearchHistoryEntry(entry);

  Future<void> clear() => _hiveSource.clearSearchHistory();
}
