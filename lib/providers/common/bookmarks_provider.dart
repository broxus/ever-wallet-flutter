import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../injection.dart';
import '../../../logger.dart';
import '../../data/models/bookmark.dart';
import '../../data/repositories/bookmarks_repository.dart';

final bookmarksProvider = StreamProvider.autoDispose<List<Bookmark>>(
  (ref) => getIt.get<BookmarksRepository>().bookmarksStream.doOnError((err, st) => logger.e(err, err, st)),
);
