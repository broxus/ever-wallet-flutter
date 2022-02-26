import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

import '../../logger.dart';
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
    _accountsStorageSource.accountsStream
        .skip(1)
        .startWith(_accountsStorageSource.accounts)
        .pairwise()
        .listen((e) => _lock.synchronized(() => _accountsStreamListener(e)));
  }

  Stream<Map<String, Permissions>> get permissionsStream => _permissionsSubject.stream;

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

  Future<void> deletePermissions(String origin) async {
    await _hiveSource.deletePermissions(origin);

    _permissionsSubject.add(_hiveSource.permissions);
  }

  Future<void> deletePermissionsForAccount(String address) async {
    await _hiveSource.deletePermissionsForAccount(address);

    _permissionsSubject.add(_hiveSource.permissions);
  }

  Future<Permissions> checkPermissions({
    required String origin,
    required List<Permission> requiredPermissions,
  }) async {
    final permissions = this.permissions[origin] ?? const Permissions();

    for (final requiredPermission in requiredPermissions) {
      switch (requiredPermission) {
        case Permission.basic:
          if (permissions.basic == null || permissions.basic == false) throw Exception('Not permitted');
          break;
        case Permission.accountInteraction:
          if (permissions.accountInteraction == null) throw Exception('Not permitted');
          break;
      }
    }

    return permissions;
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
