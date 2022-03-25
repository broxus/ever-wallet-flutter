import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../injection.dart';
import '../../../logger.dart';
import '../../data/repositories/keys_repository.dart';

final currentKeyProvider = StreamProvider.autoDispose<KeyStoreEntry?>(
  (ref) => getIt.get<KeysRepository>().currentKeyStream.doOnError((err, st) => logger.e(err, err, st)),
);
