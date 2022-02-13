import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../injection.dart';
import '../../../data/repositories/public_keys_labels_repository.dart';
import '../../../logger.dart';

final publicKeysLabelsProvider = StreamProvider<Map<String, String>>(
  (ref) => getIt.get<PublicKeysLabelsRepository>().labelsStream.doOnError((err, st) => logger.e(err, err, st)),
);
