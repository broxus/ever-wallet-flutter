import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../data/repositories/biometry_repository.dart';
import '../../../injection.dart';
import '../../models/biometry_info.dart';

final biometryInfoProvider = StreamProvider<BiometryInfo>(
  (ref) => Rx.combineLatest2<bool, bool, Tuple2<bool, bool>>(
    getIt.get<BiometryRepository>().biometryAvailabilityStream,
    getIt.get<BiometryRepository>().biometryStatusStream,
    (a, b) => Tuple2(a, b),
  ).map(
    (e) => BiometryInfo(
      isAvailable: e.item1,
      isEnabled: e.item2,
    ),
  ),
);
