import '../models/bookmark.dart';

abstract class BookmarksRepository {
  Future<List<Bookmark>> getBookmarks();

  Future<void> addBookmark(String url);

  Future<void> updateBookmark(Bookmark bookmark);

  Future<void> removeBookmark(Bookmark bookmark);

  Future<void> clear();
}
