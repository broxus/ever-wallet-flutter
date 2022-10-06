import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../injection.dart';
import '../../../logger.dart';
import '../../data/repositories/transport_repository.dart';
import '../../presentation/main/browser/events/models/network_changed_event.dart';

final networkChangesProvider = StreamProvider.autoDispose<NetworkChangedEvent>(
  (ref) => getIt
      .get<TransportRepository>()
      .transportStream
      .map(
        (e) => NetworkChangedEvent(
          selectedConnection: e.connectionData.name,
          networkId: e.connectionData.networkId,
        ),
      )
      .doOnError((err, st) => logger.e(err, err, st)),
);
