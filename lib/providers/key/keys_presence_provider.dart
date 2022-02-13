import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/repositories/keystore_repository.dart';
import '../../../injection.dart';
import '../../../logger.dart';

final keysPresenceProvider = StreamProvider<bool>(
  (ref) => getIt
      .get<KeystoreRepository>()
      .keysStream
      .map((e) => e.isNotEmpty)
      .doOnError((err, st) => logger.e(err, err, st)),
);
