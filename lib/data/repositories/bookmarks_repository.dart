import 'dart:async';
import 'dart:math';

import 'package:ever_wallet/data/models/bookmark.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

class BookmarksRepository {
  final HiveSource _hiveSource;
  final _bookmarksSubject = BehaviorSubject<List<Bookmark>>.seeded([]);

  BookmarksRepository(this._hiveSource) {
    _bookmarksSubject.add(_hiveSource.bookmarks);
  }

  Stream<List<Bookmark>> get bookmarksStream =>
      _bookmarksSubject.distinct((a, b) => listEquals(a, b));

  List<Bookmark> get bookmarks => _bookmarksSubject.value;

  Future<void> addBookmark({
    required String name,
    required String url,
  }) async {
    final ids = _hiveSource.bookmarks.map((e) => e.id);

    final id = ids.isNotEmpty ? ids.reduce(max) + 1 : 0;

    final bookmark = Bookmark(
      id: id,
      name: name,
      url: url,
    );

    await _hiveSource.putBookmark(bookmark);

    _bookmarksSubject.add(_hiveSource.bookmarks);
  }

  Future<void> editBookmark({
    required int id,
    String? newName,
    String? newUrl,
  }) async {
    var bookmark = _hiveSource.bookmarks.firstWhere((e) => e.id == id);

    if (newName != null) bookmark = bookmark.copyWith(name: newName);

    if (newUrl != null) bookmark = bookmark.copyWith(url: newUrl);

    await _hiveSource.putBookmark(bookmark);

    _bookmarksSubject.add(_hiveSource.bookmarks);
  }

  Future<void> deleteBookmark(int id) async {
    await _hiveSource.deleteBookmark(id);

    _bookmarksSubject.add(_hiveSource.bookmarks);
  }

  Future<void> clear() => _hiveSource.clearBookmarks();

  Future<void> dispose() => _bookmarksSubject.close();
}
