import 'package:injectable/injectable.dart';

import '../../domain/models/bookmark.dart';
import '../../domain/repositories/bookmarks_repository.dart';
import '../dtos/bookmark_dto.dart';
import '../sources/local/hive_source.dart';
import '../sources/remote/metadata_source.dart';

@LazySingleton(as: BookmarksRepository)
class BookmarksRepositoryImpl implements BookmarksRepository {
  final HiveSource _hiveSource;
  final MetadataSource _metadataSource;

  BookmarksRepositoryImpl(
    this._hiveSource,
    this._metadataSource,
  );

  @override
  Future<List<Bookmark>> getBookmarks() async {
    final bookmarks = _hiveSource.getBookmarks();
    return bookmarks.map((e) => e.toDomain()).toList();
  }

  @override
  Future<void> addBookmark(String url) async {
    final title = await _metadataSource.getTitle(url);
    final icon = await _metadataSource.getFavicon(url);
    final bookmark = Bookmark(
      url: url,
      title: title,
      icon: icon,
    );

    return _hiveSource.addBookmark(BookmarkDto.fromDomain(bookmark));
  }

  @override
  Future<void> updateBookmark(Bookmark bookmark) async => _hiveSource.updateBookmark(BookmarkDto.fromDomain(bookmark));

  @override
  Future<void> removeBookmark(Bookmark bookmark) async => _hiveSource.removeBookmark(BookmarkDto.fromDomain(bookmark));

  @override
  Future<void> clear() => _hiveSource.clearBookmarks();
}
