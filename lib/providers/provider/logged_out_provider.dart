import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../injection.dart';
import '../../../logger.dart';
import '../../data/repositories/keys_repository.dart';

final loggedOutProvider = StreamProvider.autoDispose<void>(
  (ref) =>
      getIt.get<KeysRepository>().keysStream.where((e) => e.isEmpty).doOnError((err, st) => logger.e(err, err, st)),
);
