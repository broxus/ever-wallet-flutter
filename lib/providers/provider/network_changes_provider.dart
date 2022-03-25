import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../injection.dart';
import '../../../logger.dart';
import '../../data/repositories/transport_repository.dart';

final networkChangesProvider = StreamProvider.autoDispose<NetworkChangedEvent>(
  (ref) => getIt
      .get<TransportRepository>()
      .transportStream
      .whereType<Transport>()
      .map(
        (e) => NetworkChangedEvent(
          selectedConnection: e.connectionData.name,
        ),
      )
      .doOnError((err, st) => logger.e(err, err, st)),
);
