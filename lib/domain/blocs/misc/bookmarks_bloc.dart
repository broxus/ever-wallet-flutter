import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:crystal/domain/models/web_metadata.dart';
import 'package:crystal/domain/repositories/bookmarks_repository.dart';
import 'package:crystal/domain/repositories/web_metadata_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../logger.dart';

part 'bookmarks_bloc.freezed.dart';

@injectable
class BookmarksBloc extends Bloc<_Event, BookmarksState> {
  final BookmarksRepository _bookmarksRepository;
  final WebMetadataRepository _webMetadataRepository;

  BookmarksBloc(
    this._bookmarksRepository,
    this._webMetadataRepository,
  ) : super(const BookmarksState.initial()) {
    add(const _LocalEvent.updateBookmarks());
  }

  @override
  Stream<BookmarksState> mapEventToState(_Event event) async* {
    if (event is _LocalEvent) {
      yield* event.when(
        updateBookmarks: () async* {
          try {
            final bookmarks = await _bookmarksRepository.getBookmarks();

            final list = <WebMetadata>[];

            if (bookmarks.isEmpty) {
              yield const BookmarksState.ready([]);
            }

            for (final bookmark in bookmarks) {
              try {
                final metadata = await _webMetadataRepository.getMetadata(bookmark);
                list.add(metadata);
                yield BookmarksState.ready([...list]);
              } catch (_) {}
            }
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield BookmarksState.error(err.toString());
          }
        },
      );
    }

    if (event is BookmarksEvent) {
      yield* event.when(
        addBookmark: (String url) async* {
          try {
            if (url != 'about:blank') {
              await _bookmarksRepository.addBookmark(url);

              add(const _LocalEvent.updateBookmarks());
            }
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield BookmarksState.error(err.toString());
          }
        },
        removeBookmark: (String url) async* {
          try {
            await _bookmarksRepository.removeBookmark(url);

            add(const _LocalEvent.updateBookmarks());
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield BookmarksState.error(err.toString());
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

  const factory BookmarksEvent.removeBookmark(String url) = _RemoveBookmark;
}

@freezed
class BookmarksState with _$BookmarksState {
  const factory BookmarksState.initial() = _Initial;

  const factory BookmarksState.ready(List<WebMetadata> bookmarks) = _Ready;

  const factory BookmarksState.error(String info) = _Error;
}
