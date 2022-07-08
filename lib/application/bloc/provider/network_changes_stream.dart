import 'package:ever_wallet/application/main/browser/events/models/network_changed_event.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';

Stream<NetworkChangedEvent> networkChangesStream(TransportRepository transportRepository) =>
    transportRepository.transportStream.map(
      (e) => NetworkChangedEvent(
        selectedConnection: e.name,
      ),
    );
