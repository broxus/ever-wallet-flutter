import 'dart:async';

import 'package:collection/collection.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/sources/local/current_accounts_source.dart';
import 'package:ever_wallet/data/sources/local/current_key_source.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/data/sources/remote/transport_source.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tuple/tuple.dart';

class AccountsRepository {
  final _lock = Lock();
  final AccountsStorage _accountsStorage;
  final CurrentAccountsSource _currentAccountsSource;
  final TransportSource _transportSource;
  final Keystore _keystore;
  final CurrentKeySource _currentKeySource;
  final HiveSource _hiveSource;
  final _externalAccountsSubject = BehaviorSubject<Map<String, List<String>>>.seeded({});
  late final StreamSubscription _keysStreamSubscription;
  late final StreamSubscription _accountsStreamSubscription;
  late final StreamSubscription _currentAccountsStreamSubscription;

  AccountsRepository(
    this._accountsStorage,
    this._currentAccountsSource,
    this._transportSource,
    this._keystore,
    this._currentKeySource,
    this._hiveSource,
  ) {
    _externalAccountsSubject.add(_hiveSource.externalAccounts);

    _keysStreamSubscription = _keystore.entriesStream
        .skip(1)
        .startWith(_keystore.entries)
        .pairwise()
        .listen((event) => _lock.synchronized(() => _keysStreamListener(event)));

    _accountsStreamSubscription = accountsStream
        .skip(1)
        .startWith(accounts)
        .pairwise()
        .listen((event) => _lock.synchronized(() => _accountsStreamListener(event)));

    _currentAccountsStreamSubscription = Rx.combineLatest3<KeyStoreEntry?, List<AssetsList>,
            Map<String, List<String>>, List<AssetsList>>(
      _currentKeySource.currentKeyStream,
      accountsStream,
      externalAccountsStream,
      (a, b, c) {
        if (a == null) return [];

        final externalAddresses = c[a.publicKey] ?? [];

        final internalAccounts = b.where((e) => e.publicKey == a.publicKey);
        final externalAccounts =
            b.where((e) => e.publicKey != a.publicKey && externalAddresses.contains(e.address));

        final list = [
          ...internalAccounts,
          ...externalAccounts,
        ]..sort();

        return list;
      },
    )
        .distinct((a, b) => listEquals(a, b))
        .listen((event) => _currentAccountsSource.currentAccounts = event);
  }

  Stream<List<AssetsList>> get accountsStream => _accountsStorage.entriesStream;

  List<AssetsList> get accounts => _accountsStorage.entries;

  Stream<Map<String, List<String>>> get externalAccountsStream =>
      _externalAccountsSubject.distinct((a, b) => const DeepCollectionEquality().equals(a, b));

  Map<String, List<String>> get externalAccounts => _externalAccountsSubject.value;

  Stream<List<AssetsList>> get currentAccountsStream =>
      _currentAccountsSource.currentAccountsStream;

  List<AssetsList> get currentAccounts => _currentAccountsSource.currentAccounts;

  Stream<Tuple2<List<WalletType>, List<WalletType>>> accountCreationOptions(String publicKey) =>
      accountsStream
          .map((e) => e.where((e) => e.publicKey == publicKey))
          .map((e) => e.map((e) => e.tonWallet.contract))
          .map((e) {
        final added = e.toList();
        final available = kAvailableWallets.where((el) => !e.contains(el)).toList();

        return Tuple2(
          added,
          available,
        );
      }).doOnError((err, st) => logger.e(err, err, st));

  Stream<AssetsList> accountInfo(String address) => accountsStream
      .expand((e) => e)
      .where((e) => e.address == address)
      .doOnError((err, st) => logger.e(err, err, st));

  Stream<List<AssetsList>> get sortedAccounts => currentAccountsStream
      .map((e) => [...e]..sort((a, b) => a.name.compareTo(b.name)))
      .doOnError((err, st) => logger.e(err, err, st));

  Stream<List<String>> get currentExternalAccounts =>
      Rx.combineLatest2<KeyStoreEntry?, Map<String, List<String>>, List<String>>(
        _currentKeySource.currentKeyStream,
        externalAccountsStream,
        (a, b) => b[a?.publicKey] ?? [],
      ).doOnError((err, st) => logger.e(err, err, st));

  Future<AssetsList> addAccount({
    required String name,
    required String publicKey,
    required WalletType walletType,
  }) =>
      _accountsStorage.addAccount(
        AccountToAdd(
          name: name,
          publicKey: publicKey,
          contract: walletType,
          workchain: kDefaultWorkchain,
        ),
      );

  Future<AssetsList> addExternalAccount({
    required String publicKey,
    required String address,
    String? name,
  }) async {
    final transport = await _transportSource.transport;

    final custodians = await getWalletCustodians(
      transport: transport,
      address: address,
    );

    final isCustodian = custodians.contains(publicKey);

    if (!isCustodian) throw Exception('Is not custodian');

    var account = accounts.firstWhereOrNull((e) => e.address == address);

    if (account == null) {
      final existingWalletInfo = await getExistingWalletInfo(
        transport: transport,
        address: address,
      );

      account = await addAccount(
        name: name ?? existingWalletInfo.walletType.name,
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
      _accountsStorage.renameAccount(
        account: address,
        name: name,
      );

  Future<AssetsList?> removeAccount(String address) => _accountsStorage.removeAccount(address);

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

    final isExternal =
        _hiveSource.externalAccounts.values.expand((e) => e).contains(account.address);
    final isLocal = _keystore.entries.map((e) => e.publicKey).contains(account.publicKey);

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
    final transport = await _transportSource.transport;

    await getTokenRootDetails(
      transport: transport,
      rootTokenContract: rootTokenContract,
    );

    final account = await _accountsStorage.addTokenWallet(
      account: address,
      rootTokenContract: rootTokenContract,
      networkGroup: transport.group,
    );

    return account;
  }

  Future<AssetsList> removeTokenWallet({
    required String address,
    required String rootTokenContract,
  }) async {
    final transport = await _transportSource.transport;

    final account = await _accountsStorage.removeTokenWallet(
      account: address,
      rootTokenContract: rootTokenContract,
      networkGroup: transport.group,
    );

    return account;
  }

  Future<void> clear() async {
    await _accountsStorage.clear();
    await _hiveSource.clearExternalAccounts();
  }

  Future<void> dispose() async {
    await _keysStreamSubscription.cancel();
    await _accountsStreamSubscription.cancel();
    await _currentAccountsStreamSubscription.cancel();

    await _externalAccountsSubject.close();
  }

  Future<void> _keysStreamListener(Iterable<List<KeyStoreEntry>> event) async {
    try {
      final prev = event.first;
      final next = event.last;

      final addedKeys = [...next]
        ..removeWhere((e) => prev.any((el) => el.publicKey == e.publicKey));
      final removedKeys = [...prev]
        ..removeWhere((e) => next.any((el) => el.publicKey == e.publicKey));

      for (final key in addedKeys) {
        try {
          final transport = await _transportSource.transport;

          final wallets = await findExistingWallets(
            transport: transport,
            publicKey: key.publicKey,
            workchainId: kDefaultWorkchain,
            walletTypes: kAvailableWallets,
          );

          final activeWallets = wallets.where((e) => e.isActive);

          for (final activeWallet in activeWallets) {
            final isExists = accounts.any((e) => e.address == activeWallet.address);

            if (!isExists) {
              try {
                await addAccount(
                  name: activeWallet.walletType.name,
                  publicKey: activeWallet.publicKey,
                  walletType: activeWallet.walletType,
                );
              } catch (err, st) {
                logger.e(err, err, st);
              }
            }
          }
        } catch (err, st) {
          logger.e(err, err, st);
        }
      }

      for (final key in removedKeys) {
        final accounts = this.accounts.where((e) => e.publicKey == key.publicKey);

        for (final account in accounts) {
          try {
            await removeAccount(account.address);
          } catch (err, st) {
            logger.e(err, err, st);
          }
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

      final removedAccounts = [...prev]
        ..removeWhere((e) => next.any((el) => el.address == e.address));

      for (final account in removedAccounts) {
        final externalAccounts = this
            .externalAccounts
            .entries
            .map((e) => e.value.map((el) => Tuple2(e.key, el)))
            .expand((e) => e)
            .where((e) => e.item2 == account.address);

        for (final externalAccount in externalAccounts) {
          try {
            await removeExternalAccount(
              publicKey: externalAccount.item1,
              address: externalAccount.item2,
            );
          } catch (err, st) {
            logger.e(err, err, st);
          }
        }
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
