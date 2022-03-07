import 'dart:async';

import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tuple/tuple.dart';

import '../../logger.dart';
import '../constants.dart';
import '../extensions.dart';
import '../sources/local/accounts_storage_source.dart';
import '../sources/local/hive_source.dart';
import '../sources/local/keystore_source.dart';
import '../sources/remote/transport_source.dart';

@preResolve
@lazySingleton
class AccountsRepository {
  final AccountsStorageSource _accountsStorageSource;
  final TransportSource _transportSource;
  final KeystoreSource _keystoreSource;
  final HiveSource _hiveSource;
  final _externalAccountsSubject = BehaviorSubject<Map<String, List<String>>>.seeded({});
  final _lock = Lock();

  AccountsRepository._(
    this._accountsStorageSource,
    this._transportSource,
    this._keystoreSource,
    this._hiveSource,
  );

  @factoryMethod
  static Future<AccountsRepository> create({
    required AccountsStorageSource accountsStorageSource,
    required TransportSource transportSource,
    required KeystoreSource keystoreSource,
    required HiveSource hiveSource,
  }) async {
    final instance = AccountsRepository._(
      accountsStorageSource,
      transportSource,
      keystoreSource,
      hiveSource,
    );
    await instance._initialize();
    return instance;
  }

  Stream<List<AssetsList>> get accountsStream => _accountsStorageSource.accountsStream;

  List<AssetsList> get accounts => _accountsStorageSource.accounts;

  Stream<Map<String, List<String>>> get externalAccountsStream =>
      _externalAccountsSubject.distinct((a, b) => const DeepCollectionEquality().equals(a, b));

  Map<String, List<String>> get externalAccounts => _externalAccountsSubject.value;

  Stream<List<AssetsList>> get currentAccountsStream => _accountsStorageSource.currentAccountsStream;

  List<AssetsList> get currentAccounts => _accountsStorageSource.currentAccounts;

  Future<AssetsList> addAccount({
    required String name,
    required String publicKey,
    required WalletType walletType,
  }) =>
      _accountsStorageSource.addAccount(
        name: name,
        publicKey: publicKey,
        walletType: walletType,
        workchain: kDefaultWorkchain,
      );

  Future<AssetsList> addExternalAccount({
    required String publicKey,
    required String address,
    String? name,
  }) async {
    final transport = _transportSource.transport;

    if (transport == null) throw Exception('Transport unavailable');

    final custodians = await getWalletCustodians(
      transport: transport,
      address: address,
    );

    final isCustodian = custodians.contains(publicKey);

    if (!isCustodian) throw Exception('Is not custodian');

    AssetsList? account = accounts.firstWhereOrNull((e) => e.address == address);

    if (account == null) {
      final existingWalletInfo = await getExistingWalletInfo(
        transport: transport,
        address: address,
      );

      account = await addAccount(
        name: name ?? existingWalletInfo.walletType.describe(),
        publicKey: existingWalletInfo.publicKey,
        walletType: existingWalletInfo.walletType,
      );
    }

    await _hiveSource.addExternalAccount(
      publicKey: publicKey,
      address: address,
    );

    _externalAccountsSubject.add(_hiveSource.externalAccounts);

    return account;
  }

  Future<AssetsList> renameAccount({
    required String address,
    required String name,
  }) =>
      _accountsStorageSource.renameAccount(
        address: address,
        name: name,
      );

  Future<AssetsList?> removeAccount(String address) => _accountsStorageSource.removeAccount(address);

  Future<AssetsList?> removeExternalAccount({
    required String publicKey,
    required String address,
  }) async {
    await _hiveSource.removeExternalAccount(
      publicKey: publicKey,
      address: address,
    );

    _externalAccountsSubject.add(_hiveSource.externalAccounts);

    final account = accounts.firstWhereOrNull((e) => e.address == address);

    if (account == null) return null;

    final isExternal = _hiveSource.externalAccounts.values.expand((e) => e).contains(account.address);
    final isLocal = _keystoreSource.keys.map((e) => e.publicKey).contains(account.publicKey);

    if (!isExternal && !isLocal) {
      final removedAccount = await removeAccount(account.address);

      return removedAccount;
    } else {
      return null;
    }
  }

  Future<AssetsList> addTokenWallet({
    required String address,
    required String rootTokenContract,
  }) async {
    final transport = _transportSource.transport;

    if (transport == null) throw Exception('Transport unavailable');

    await getTokenRootDetails(
      transport: transport,
      rootTokenContract: rootTokenContract,
    );

    final account = await _accountsStorageSource.addTokenWallet(
      address: address,
      rootTokenContract: rootTokenContract,
      networkGroup: transport.connectionData.group,
    );

    return account;
  }

  Future<AssetsList> removeTokenWallet({
    required String address,
    required String rootTokenContract,
  }) async {
    final transport = _transportSource.transport;

    if (transport == null) throw Exception('Transport unavailable');

    final account = await _accountsStorageSource.removeTokenWallet(
      address: address,
      rootTokenContract: rootTokenContract,
      networkGroup: transport.connectionData.group,
    );

    return account;
  }

  Future<void> clear() async {
    await _accountsStorageSource.clear();
    await _hiveSource.clearExternalAccounts();
  }

  Future<void> _initialize() async {
    _keystoreSource.keysStream
        .skip(1)
        .startWith(_keystoreSource.keys)
        .pairwise()
        .listen((event) => _lock.synchronized(() => _keysStreamListener(event)));

    accountsStream
        .skip(1)
        .startWith(accounts)
        .pairwise()
        .listen((event) => _lock.synchronized(() => _accountsStreamListener(event)));

    Rx.combineLatest3<KeyStoreEntry?, List<AssetsList>, Map<String, List<String>>, List<AssetsList>>(
      _keystoreSource.currentKeyStream,
      accountsStream,
      externalAccountsStream,
      (a, b, c) {
        if (a == null) return [];

        final externalAddresses = c[a.publicKey] ?? [];

        final internalAccounts = b.where((e) => e.publicKey == a.publicKey);
        final externalAccounts = b.where((e) => e.publicKey != a.publicKey && externalAddresses.contains(e.address));

        final list = [
          ...internalAccounts,
          ...externalAccounts,
        ]..sort();

        return list;
      },
    ).listen((event) => _accountsStorageSource.currentAccounts = event);
  }

  Future<void> _keysStreamListener(Iterable<List<KeyStoreEntry>> event) async {
    try {
      final prev = event.first;
      final next = event.last;

      final addedKeys = [...next]..removeWhere((e) => prev.any((el) => el.publicKey == e.publicKey));
      final removedKeys = [...prev]..removeWhere((e) => next.any((el) => el.publicKey == e.publicKey));

      for (final key in addedKeys) {
        final transport = _transportSource.transport;

        if (transport == null) throw Exception('Transport unavailable');

        final wallets = await findExistingWallets(
          transport: transport,
          publicKey: key.publicKey,
          workchainId: kDefaultWorkchain,
        );

        final activeWallets = wallets.where((e) => e.isActive);

        for (final activeWallet in activeWallets) {
          final isExists = accounts.any((e) => e.address == activeWallet.address);

          if (!isExists) {
            await addAccount(
              name: activeWallet.walletType.describe(),
              publicKey: activeWallet.publicKey,
              walletType: activeWallet.walletType,
            );
          }
        }
      }

      for (final key in removedKeys) {
        final accounts = this.accounts.where((e) => e.publicKey == key.publicKey);

        for (final account in accounts) {
          await removeAccount(account.address);
        }
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<void> _accountsStreamListener(Iterable<List<AssetsList>> event) async {
    try {
      final prev = event.first;
      final next = event.last;

      final removedAccounts = [...prev]..removeWhere((e) => next.any((el) => el.address == e.address));

      for (final account in removedAccounts) {
        final externalAccounts = this
            .externalAccounts
            .entries
            .map((e) => e.value.map((el) => Tuple2(e.key, el)))
            .expand((e) => e)
            .where((e) => e.item2 == account.address);

        for (final externalAccount in externalAccounts) {
          await removeExternalAccount(
            publicKey: externalAccount.item1,
            address: externalAccount.item2,
          );
        }
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
