import 'dart:async';

import 'package:ever_wallet/data/models/permissions.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/logger.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

class PermissionsRepository {
  final _lock = Lock();
  final AccountsStorage _accountsStorage;
  final HiveSource _hiveSource;
  final _permissionsSubject = BehaviorSubject<Map<String, Permissions>>.seeded({});
  late final StreamSubscription _accountsStreamSubscription;

  PermissionsRepository(
    this._accountsStorage,
    this._hiveSource,
  ) {
    _permissionsSubject.add(_hiveSource.permissions);

    _accountsStreamSubscription = _accountsStorage.entriesStream
        .skip(1)
        .startWith(_accountsStorage.entries)
        .pairwise()
        .listen((e) => _lock.synchronized(() => _accountsStreamListener(e)));
  }

  Stream<Map<String, Permissions>> get permissionsStream => _permissionsSubject;

  Map<String, Permissions> get permissions => _permissionsSubject.value;

  Future<void> setPermissions({
    required String origin,
    required Permissions permissions,
  }) async {
    await _hiveSource.setPermissions(
      origin: origin,
      permissions: permissions,
    );

    _permissionsSubject.add(_hiveSource.permissions);
  }

  Future<void> deletePermissionsForOrigin(String origin) async {
    await _hiveSource.deletePermissionsForOrigin(origin);

    _permissionsSubject.add(_hiveSource.permissions);
  }

  Future<void> deletePermissionsForAccount(String address) async {
    await _hiveSource.deletePermissionsForAccount(address);

    _permissionsSubject.add(_hiveSource.permissions);
  }

  Future<void> dispose() async {
    await _accountsStreamSubscription.cancel();

    await _permissionsSubject.close();
  }

  Future<void> _accountsStreamListener(Iterable<List<AssetsList>> event) async {
    try {
      final prev = event.first;
      final next = event.last;

      final removedAccounts = [...prev]
        ..removeWhere((e) => next.any((el) => el.address == e.address));

      for (final account in removedAccounts) {
        await deletePermissionsForAccount(account.address);
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
