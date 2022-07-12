import 'package:ever_wallet/application/main/browser/events/models/permissions_changed_event.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:tuple/tuple.dart';

Stream<List<Tuple2<String, PermissionsChangedEvent>>> permissionsStream(
  PermissionsRepository permissionsRepository,
) =>
    permissionsRepository.permissionsStream.map(
      (e) => e.entries
          .map(
            (e) => Tuple2(
              e.key,
              PermissionsChangedEvent(
                permissions: e.value,
              ),
            ),
          )
          .toList(),
    );
