import 'dart:async';

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
    required String url,
    required Bookmark bookmark,
  }) async {
    await _hiveSource.addBookmark(
      url: url,
      bookmark: bookmark,
    );

    _bookmarksSubject.add(_hiveSource.bookmarks);
  }

  Future<void> removeBookmark(String url) async {
    await _hiveSource.removeBookmark(url);

    _bookmarksSubject.add(_hiveSource.bookmarks);
  }

  Future<void> clear() => _hiveSource.clearBookmarks();

  Future<void> _initialize() async {
    _bookmarksSubject.add(_hiveSource.bookmarks);
  }
}
