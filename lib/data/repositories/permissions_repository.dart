import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:ever_wallet/data/models/account_removed_event.dart';
import 'package:ever_wallet/data/models/permissions.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/logger.dart';
import 'package:synchronized/synchronized.dart';

class PermissionsRepository {
  final _lock = Lock();
  final HiveSource _hiveSource;
  final EventBus _eventBus;
  late final StreamSubscription _accountRemovedStreamSubscription;

  PermissionsRepository({
    required HiveSource hiveSource,
    required EventBus eventBus,
  })  : _hiveSource = hiveSource,
        _eventBus = eventBus {
    _accountRemovedStreamSubscription = _eventBus
        .on<AccountRemovedEvent>()
        .listen((e) => _lock.synchronized(() => _accountRemovedStreamListener(e)));
  }

  Stream<Map<String, Permissions>> get permissionsStream => _hiveSource.permissionsStream;

  Map<String, Permissions> get permissions => _hiveSource.permissions;

  Future<void> setPermissions({
    required String origin,
    required Permissions permissions,
  }) =>
      _hiveSource.setPermissions(
        origin: origin,
        permissions: permissions,
      );

  Future<void> deletePermissionsForOrigin(String origin) =>
      _hiveSource.deletePermissionsForOrigin(origin);

  Future<void> deletePermissionsForAccount(String address) =>
      _hiveSource.deletePermissionsForAccount(address);

  Future<void> dispose() => _accountRemovedStreamSubscription.cancel();

  Future<void> _accountRemovedStreamListener(AccountRemovedEvent event) async {
    try {
      await deletePermissionsForAccount(event.account.address);
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
