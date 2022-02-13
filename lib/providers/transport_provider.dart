import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../injection.dart';
import '../../data/repositories/transport_repository.dart';
import '../../logger.dart';

final transportProvider = StreamProvider<ConnectionData>(
  (ref) => getIt
      .get<TransportRepository>()
      .transportStream
      .map((e) => e.connectionData)
      .doOnError((err, st) => logger.e(err, err, st)),
);
