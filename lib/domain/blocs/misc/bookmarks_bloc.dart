import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../models/bookmark.dart';
import '../../repositories/bookmarks_repository.dart';

part 'bookmarks_bloc.freezed.dart';

@injectable
class BookmarksBloc extends Bloc<_Event, List<Bookmark>> {
  final BookmarksRepository _bookmarksRepository;
  final _errorsSubject = PublishSubject<String>();

  BookmarksBloc(this._bookmarksRepository) : super(const []) {
    add(const _LocalEvent.update());
  }

  @override
  Future<void> close() {
    _errorsSubject.close();
    return super.close();
  }

  @override
  Stream<List<Bookmark>> mapEventToState(_Event event) async* {
    try {
      if (event is _Update) {
        final bookmarks = await _bookmarksRepository.getBookmarks();

        yield [...bookmarks];
      } else if (event is _Add) {
        await _bookmarksRepository.addBookmark(event.url);

        add(const _LocalEvent.update());
      } else if (event is _Remove) {
        await _bookmarksRepository.removeBookmark(event.bookmark);

        add(const _LocalEvent.update());
      }
    } catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err.toString());
    }
  }

  Stream<String> get errorsStream => _errorsSubject.stream;
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.update() = _Update;
}

@freezed
class BookmarksEvent extends _Event with _$BookmarksEvent {
  const factory BookmarksEvent.add(String url) = _Add;

  const factory BookmarksEvent.remove(Bookmark bookmark) = _Remove;
}
