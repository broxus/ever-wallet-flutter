import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../injection.dart';
import '../../../logger.dart';
import '../../data/repositories/keys_repository.dart';

final keysPresenceProvider = StreamProvider<bool>(
  (ref) =>
      getIt.get<KeysRepository>().keysStream.map((e) => e.isNotEmpty).doOnError((err, st) => logger.e(err, err, st)),
);
