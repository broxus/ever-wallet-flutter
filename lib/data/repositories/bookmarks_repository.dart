import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../models/bookmark.dart';
import '../sources/local/hive_source.dart';

@preResolve
@lazySingleton
class BookmarksRepository {
  final HiveSource _hiveSource;
  final _bookmarksSubject = BehaviorSubject<List<Bookmark>>.seeded([]);

  BookmarksRepository._(this._hiveSource);

  @factoryMethod
  static Future<BookmarksRepository> create({
    required HiveSource hiveSource,
  }) async {
    final instance = BookmarksRepository._(hiveSource);
    await instance._initialize();
    return instance;
  }

  Stream<List<Bookmark>> get bookmarksStream => _bookmarksSubject.distinct((a, b) => listEquals(a, b));

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

  Future<void> _initialize() async => _bookmarksSubject.add(_hiveSource.bookmarks);
}
