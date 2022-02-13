import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/repositories/current_key_repository.dart';
import '../../../injection.dart';
import '../../../logger.dart';

final currentKeyProvider = StreamProvider<KeyStoreEntry?>(
  (ref) => getIt.get<CurrentKeyRepository>().currentKeyStream.doOnError((err, st) => logger.e(err, err, st)),
);
