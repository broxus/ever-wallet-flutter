import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/repositories/keystore_repository.dart';
import '../../../injection.dart';
import '../../../logger.dart';

final keyInfoProvider = StreamProvider.family<KeyStoreEntry, String>(
  (ref, publicKey) => getIt
      .get<KeystoreRepository>()
      .keysStream
      .expand((e) => e)
      .where((e) => e.publicKey == publicKey)
      .doOnError((err, st) => logger.e(err, err, st)),
);
