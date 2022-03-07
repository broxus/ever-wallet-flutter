import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import 'storage_source.dart';

@preResolve
@lazySingleton
class AccountsStorageSource {
  late final AccountsStorage _accountsStorage;
  final _accountsSubject = BehaviorSubject<List<AssetsList>>.seeded([]);
  final _currentAccountsSubject = BehaviorSubject<List<AssetsList>>.seeded([]);

  AccountsStorageSource._();

  @factoryMethod
  static Future<AccountsStorageSource> create({
    required StorageSource storageSource,
  }) async {
    final instance = AccountsStorageSource._();
    await instance._initialize(
      storageSource: storageSource,
    );
    return instance;
  }

  Stream<List<AssetsList>> get accountsStream => _accountsSubject.distinct((a, b) => listEquals(a, b));

  List<AssetsList> get accounts => _accountsSubject.value;

  Stream<List<AssetsList>> get currentAccountsStream => _currentAccountsSubject.distinct((a, b) => listEquals(a, b));

  List<AssetsList> get currentAccounts => _currentAccountsSubject.value;

  set currentAccounts(List<AssetsList> accounts) => _currentAccountsSubject.add(accounts);

  Future<AssetsList> addAccount({
    required String name,
    required String publicKey,
    required WalletType walletType,
    required int workchain,
  }) async {
    final account = await _accountsStorage.addAccount(
      name: name,
      publicKey: publicKey,
      walletType: walletType,
      workchain: workchain,
    );

    _accountsSubject.add(await _accountsStorage.accounts);

    return account;
  }

  Future<AssetsList> renameAccount({
    required String address,
    required String name,
  }) async {
    final account = await _accountsStorage.renameAccount(
      address: address,
      name: name,
    );

    _accountsSubject.add(await _accountsStorage.accounts);

    return account;
  }

  Future<AssetsList?> removeAccount(String address) async {
    final account = await _accountsStorage.removeAccount(address);

    _accountsSubject.add(await _accountsStorage.accounts);

    return account;
  }

  Future<AssetsList> addTokenWallet({
    required String address,
    required String rootTokenContract,
    required String networkGroup,
  }) async {
    final account = await _accountsStorage.addTokenWallet(
      address: address,
      rootTokenContract: rootTokenContract,
      networkGroup: networkGroup,
    );

    _accountsSubject.add(await _accountsStorage.accounts);

    return account;
  }

  Future<AssetsList> removeTokenWallet({
    required String address,
    required String rootTokenContract,
    required String networkGroup,
  }) async {
    final account = await _accountsStorage.removeTokenWallet(
      address: address,
      rootTokenContract: rootTokenContract,
      networkGroup: networkGroup,
    );

    _accountsSubject.add(await _accountsStorage.accounts);

    return account;
  }

  Future<void> clear() async {
    await _accountsStorage.clear();

    _accountsSubject.add(await _accountsStorage.accounts);
  }

  Future<void> _initialize({
    required StorageSource storageSource,
  }) async {
    _accountsStorage = await AccountsStorage.create(storageSource.storage);

    _accountsSubject.add(await _accountsStorage.accounts);
  }
}
