import 'dart:async';
import 'dart:math';

import 'package:ever_wallet/data/models/bookmark.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';

class BookmarksRepository {
  final HiveSource _hiveSource;

  BookmarksRepository(this._hiveSource);

  Stream<List<Bookmark>> get bookmarksStream => _hiveSource.bookmarksStream;

  List<Bookmark> get bookmarks => _hiveSource.bookmarks;

  Future<Bookmark> addBookmark({
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

    await _hiveSource.addBookmark(bookmark);

    return bookmark;
  }

  Future<void> editBookmark({
    required int id,
    String? newName,
    String? newUrl,
  }) async {
    var bookmark = _hiveSource.bookmarks.firstWhere((e) => e.id == id);

    if (newName != null) bookmark = bookmark.copyWith(name: newName);

    if (newUrl != null) bookmark = bookmark.copyWith(url: newUrl);

    await _hiveSource.addBookmark(bookmark);
  }

  Future<void> deleteBookmark(int id) => _hiveSource.deleteBookmark(id);

  Future<void> clear() => _hiveSource.clearBookmarks();
}
