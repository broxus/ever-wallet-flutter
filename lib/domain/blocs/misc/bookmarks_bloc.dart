import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../logger.dart';
import '../../models/bookmark.dart';
import '../../repositories/bookmarks_repository.dart';

part 'bookmarks_bloc.freezed.dart';

@injectable
class BookmarksBloc extends Bloc<_Event, BookmarksState> {
  final BookmarksRepository _bookmarksRepository;

  BookmarksBloc(
    this._bookmarksRepository,
  ) : super(const BookmarksState.ready([])) {
    add(const _LocalEvent.updateBookmarks());
  }

  @override
  Stream<BookmarksState> mapEventToState(_Event event) async* {
    if (event is _LocalEvent) {
      yield* event.when(
        updateBookmarks: () async* {
          try {
            final bookmarks = await _bookmarksRepository.getBookmarks();

            yield BookmarksState.ready(bookmarks);
          } on Exception catch (err, st) {
            logger.e(err, err, st);
          }
        },
      );
    }

    if (event is BookmarksEvent) {
      yield* event.when(
        addBookmark: (String url) async* {
          try {
            await _bookmarksRepository.addBookmark(url);

            add(const _LocalEvent.updateBookmarks());
          } on Exception catch (err, st) {
            logger.e(err, err, st);
          }
        },
        removeBookmark: (Bookmark bookmark) async* {
          try {
            await _bookmarksRepository.removeBookmark(bookmark);

            add(const _LocalEvent.updateBookmarks());
          } on Exception catch (err, st) {
            logger.e(err, err, st);
          }
        },
      );
    }
  }
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.updateBookmarks() = _UpdateBookmarks;
}

@freezed
class BookmarksEvent extends _Event with _$BookmarksEvent {
  const factory BookmarksEvent.addBookmark(String url) = _AddBookmark;

  const factory BookmarksEvent.removeBookmark(Bookmark bookmark) = _RemoveBookmark;
}

@freezed
class BookmarksState with _$BookmarksState {
  const factory BookmarksState.ready(List<Bookmark> bookmarks) = _Ready;
}
