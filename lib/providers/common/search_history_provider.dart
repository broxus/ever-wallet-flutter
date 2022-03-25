import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../injection.dart';
import '../../../logger.dart';
import '../../data/repositories/search_history_repository.dart';

final searchHistoryProvider = StreamProvider.autoDispose<List<String>>(
  (ref) => getIt.get<SearchHistoryRepository>().searchHistoryStream.doOnError((err, st) => logger.e(err, err, st)),
);
