import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

import '../../logger.dart';
import '../sources/local/hive_source.dart';
import 'accounts_storage_repository.dart';
import 'approvals_repository.dart';

@lazySingleton
class PermissionsRepository {
  final ApprovalsRepository _approvalsRepository;
  final HiveSource _hiveSource;
  final AccountsStorageRepository _accountsStorageRepository;
  final _permissionsSubject = BehaviorSubject<Permissions>.seeded(const Permissions());

  PermissionsRepository(
    this._approvalsRepository,
    this._hiveSource,
    this._accountsStorageRepository,
  ) {
    final lock = Lock();
    _accountsStorageRepository.accountsStream
        .skip(1)
        .startWith(_accountsStorageRepository.accounts)
        .pairwise()
        .listen((e) => lock.synchronized(() => _accountsStreamListener(e)));
  }

  Stream<Permissions> get permissionsStream => _permissionsSubject.stream;

  Future<Permissions> requestPermissions({
    required String origin,
    required List<Permission> permissions,
  }) async {
    late Permissions requested;

    try {
      requested = await checkPermissions(
        origin: origin,
        requiredPermissions: permissions,
      );
    } catch (err) {
      requested = await _approvalsRepository.requestApprovalForPermissions(
        origin: origin,
        permissions: permissions,
      );

      await _hiveSource.setPermissions(
        origin: origin,
        permissions: requested,
      );
    }

    _permissionsSubject.add(requested);

    return requested;
  }

  Future<void> removeOrigin(String origin) async {
    await _hiveSource.deletePermissions(origin);

    _permissionsSubject.add(const Permissions());
  }

  Future<void> deletePermissionsForAccount(String address) => _hiveSource.deletePermissionsForAccount(address);

  Permissions getPermissions(String origin) => _hiveSource.getPermissions(origin);

  Future<Permissions> checkPermissions({
    required String origin,
    required List<Permission> requiredPermissions,
  }) async {
    final permissions = getPermissions(origin);

    for (final requiredPermission in requiredPermissions) {
      switch (requiredPermission) {
        case Permission.tonClient:
          if (permissions.tonClient == null || permissions.tonClient == false) {
            throw Exception('Not permitted');
          }
          break;
        case Permission.accountInteraction:
          if (permissions.accountInteraction == null) {
            throw Exception('Not permitted');
          }
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
