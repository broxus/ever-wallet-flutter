import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../injection.dart';
import '../../../logger.dart';
import '../../data/repositories/keys_repository.dart';

final keysPresenceProvider = StreamProvider.autoDispose<bool>(
  (ref) => getIt
      .get<KeysRepository>()
      .keysStream
      .map((e) => e.isNotEmpty)
      .distinct()
      .doOnError((err, st) => logger.e(err, err, st)),
);
