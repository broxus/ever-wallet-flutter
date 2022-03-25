import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/repositories/biometry_repository.dart';
import '../../../injection.dart';
import '../../../logger.dart';

final biometryAvailabilityProvider = StreamProvider.autoDispose<bool>(
  (ref) => getIt.get<BiometryRepository>().availabilityStream.doOnError((err, st) => logger.e(err, err, st)),
);
