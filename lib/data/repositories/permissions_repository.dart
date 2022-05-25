import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

import '../../logger.dart';
import '../models/permissions.dart';
import '../sources/local/accounts_storage_source.dart';
import '../sources/local/hive_source.dart';

@lazySingleton
class PermissionsRepository {
  final AccountsStorageSource _accountsStorageSource;
  final HiveSource _hiveSource;
  final _permissionsSubject = BehaviorSubject<Map<String, Permissions>>.seeded({});
  final _lock = Lock();

  PermissionsRepository(
    this._accountsStorageSource,
    this._hiveSource,
  ) {
    _permissionsSubject.add(_hiveSource.permissions);

    _accountsStorageSource.accountsStream
        .skip(1)
        .startWith(_accountsStorageSource.accounts)
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

  Future<void> _accountsStreamListener(Iterable<List<AssetsList>> event) async {
    try {
      final prev = event.first;
      final next = event.last;

      final removedAccounts = [...prev]..removeWhere((e) => next.any((el) => el.address == e.address));

      for (final account in removedAccounts) {
        await deletePermissionsForAccount(account.address);
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
