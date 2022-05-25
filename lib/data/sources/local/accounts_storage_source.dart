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

  Future<AssetsList> addAccount(AccountToAdd newAccount) async {
    final account = await _accountsStorage.addAccount(newAccount);

    _accountsSubject.add(await _accountsStorage.accounts);

    return account;
  }

  Future<List<AssetsList>> addAccounts(List<AccountToAdd> newAccounts) async {
    final accounts = await _accountsStorage.addAccounts(newAccounts);

    _accountsSubject.add(await _accountsStorage.accounts);

    return accounts;
  }

  Future<AssetsList> renameAccount({
    required String account,
    required String name,
  }) async {
    final renamedAccount = await _accountsStorage.renameAccount(
      account: account,
      name: name,
    );

    _accountsSubject.add(await _accountsStorage.accounts);

    return renamedAccount;
  }

  Future<AssetsList> addTokenWallet({
    required String account,
    required String networkGroup,
    required String rootTokenContract,
  }) async {
    final updatedAccount = await _accountsStorage.addTokenWallet(
      account: account,
      rootTokenContract: rootTokenContract,
      networkGroup: networkGroup,
    );

    _accountsSubject.add(await _accountsStorage.accounts);

    return updatedAccount;
  }

  Future<AssetsList> removeTokenWallet({
    required String account,
    required String networkGroup,
    required String rootTokenContract,
  }) async {
    final updatedAccount = await _accountsStorage.removeTokenWallet(
      account: account,
      rootTokenContract: rootTokenContract,
      networkGroup: networkGroup,
    );

    _accountsSubject.add(await _accountsStorage.accounts);

    return updatedAccount;
  }

  Future<AssetsList?> removeAccount(String account) async {
    final removedAccount = await _accountsStorage.removeAccount(account);

    _accountsSubject.add(await _accountsStorage.accounts);

    return removedAccount;
  }

  Future<List<AssetsList>> removeAccounts(List<String> accounts) async {
    final removedAccounts = await _accountsStorage.removeAccounts(accounts);

    _accountsSubject.add(await _accountsStorage.accounts);

    return removedAccounts;
  }

  Future<void> clear() async {
    await _accountsStorage.clear();

    _accountsSubject.add(await _accountsStorage.accounts);
  }

  Future<void> reload() async {
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
