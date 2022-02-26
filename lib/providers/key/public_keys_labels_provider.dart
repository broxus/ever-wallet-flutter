import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../injection.dart';
import '../../../logger.dart';
import '../../data/repositories/keys_repository.dart';

final publicKeysLabelsProvider = StreamProvider<Map<String, String>>(
  (ref) => getIt.get<KeysRepository>().labelsStream.doOnError((err, st) => logger.e(err, err, st)),
);
