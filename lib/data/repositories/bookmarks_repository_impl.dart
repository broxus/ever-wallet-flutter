import 'package:crystal/domain/repositories/bookmarks_repository.dart';
import 'package:injectable/injectable.dart';

import '../sources/local/hive_source.dart';

@LazySingleton(as: BookmarksRepository)
class BookmarksRepositoryImpl implements BookmarksRepository {
  final HiveSource _hiveSource;

  BookmarksRepositoryImpl(this._hiveSource);

  @override
  Future<List<String>> getBookmarks() async => _hiveSource.getBookmarks();

  @override
  Future<void> addBookmark(String url) async => _hiveSource.addBookmark(url);

  @override
  Future<void> removeBookmark(String url) async => _hiveSource.removeBookmark(url);
}
