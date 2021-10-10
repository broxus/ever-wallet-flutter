abstract class BookmarksRepository {
  Future<List<String>> getBookmarks();

  Future<void> addBookmark(String url);

  Future<void> removeBookmark(String url);
}
