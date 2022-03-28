import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tuple/tuple.dart';

import '../../logger.dart';
import '../constants.dart';
import '../extensions.dart';
import '../models/ton_wallet_info.dart';
import '../sources/local/accounts_storage_source.dart';
import '../sources/local/hive_source.dart';
import '../sources/local/keystore_source.dart';
import '../sources/remote/transport_source.dart';

@lazySingleton
class TonWalletsRepository {
  final AccountsStorageSource _accountsStorageSource;
  final TransportSource _transportSource;
  final KeystoreSource _keystoreSource;
  final HiveSource _hiveSource;
  final _tonWalletsSubject = BehaviorSubject<List<TonWallet>>.seeded([]);
  final _lock = Lock();

  TonWalletsRepository(
    this._accountsStorageSource,
    this._transportSource,
    this._keystoreSource,
    this._hiveSource,
  ) {
    Rx.combineLatest3<List<AssetsList>, Transport, void, Tuple2<List<AssetsList>, Transport>>(
      _accountsStorageSource.currentAccountsStream,
      _transportSource.transportStream,
      Stream<void>.periodic(kSubscriptionRefreshTimeout).startWith(null),
      (a, b, c) => Tuple2(a, b),
    ).listen((event) => _lock.synchronized(() => _currentAccountsStreamListener(event)));

    _accountsStorageSource.accountsStream
        .skip(1)
        .startWith(const [])
        .pairwise()
        .listen((event) => _lock.synchronized(() => _accountsStreamListener(event)));
  }

  Future<TonWalletInfo> getInfo(String address) async {
    final tonWallet = await _getTonWallet(address);

    final tonWalletInfo = TonWalletInfo(
      workchain: await tonWallet.workchain,
      address: await tonWallet.address,
      publicKey: await tonWallet.publicKey,
      walletType: await tonWallet.walletType,
      contractState: await tonWallet.contractState,
      details: await tonWallet.details,
      custodians: await tonWallet.custodians,
    );

    await _hiveSource.saveTonWalletInfo(
      address: address,
      group: tonWallet.transport.connectionData.group,
      info: tonWalletInfo,
    );

    return tonWalletInfo;
  }

  Stream<TonWalletInfo?> getInfoStream(String address) => _tonWalletsSubject
      .asyncMap((e) async => e.asyncFirstWhere((e) async => await e.address == address))
      .flatMap((v) => v.stateChangesStream.cast<ContractState?>().startWith(null).map((e) => v))
      .asyncMap(
        (e) async {
          final tonWalletInfo = TonWalletInfo(
            workchain: await e.workchain,
            address: await e.address,
            publicKey: await e.publicKey,
            walletType: await e.walletType,
            contractState: await e.contractState,
            details: await e.details,
            custodians: await e.custodians,
          );

          await _hiveSource.saveTonWalletInfo(
            address: address,
            group: e.transport.connectionData.group,
            info: tonWalletInfo,
          );

          return tonWalletInfo;
        },
      )
      .cast<TonWalletInfo?>()
      .onErrorReturn(null)
      .distinct();

  Stream<List<TonWalletTransactionWithData>?> getTransactionsStream(String address) => _tonWalletsSubject
      .asyncMap((e) async => e.asyncFirstWhere((e) async => await e.address == address))
      .flatMap(
        (v) => v.transactionsStream.asyncMap(
          (e) async {
            final group = v.transport.connectionData.group;

            final cached = _hiveSource.getTonWalletTransactions(
              address: address,
              group: group,
            );

            final list = [
              ...{
                if (cached != null) ...cached,
                ...e,
              }
            ]..sort((a, b) => a.transaction.compareTo(b.transaction));

            await _hiveSource.saveTonWalletTransactions(
              address: address,
              group: group,
              transactions: list,
            );

            return list;
          },
        ),
      )
      .cast<List<TonWalletTransactionWithData>?>()
      .onErrorReturn(null)
      .distinct((a, b) => listEquals(a, b));

  Stream<List<PendingTransaction>?> getPendingTransactionsStream(String address) => _tonWalletsSubject
      .asyncMap((e) async => e.asyncFirstWhere((e) async => await e.address == address))
      .flatMap((v) => v.pendingTransactionsStream)
      .cast<List<PendingTransaction>?>()
      .onErrorReturn(null)
      .distinct((a, b) => listEquals(a, b));

  Stream<List<MultisigPendingTransaction>?> getUnconfirmedTransactionsStream(String address) => _tonWalletsSubject
      .asyncMap((e) async => e.asyncFirstWhere((e) async => await e.address == address))
      .flatMap((v) => v.unconfirmedTransactionsStream)
      .cast<List<MultisigPendingTransaction>?>()
      .onErrorReturn(null)
      .distinct((a, b) => listEquals(a, b));

  Stream<List<Tuple2<PendingTransaction, Transaction?>>?> getSentMessagesStream(String address) => _tonWalletsSubject
      .asyncMap((e) async => e.asyncFirstWhere((e) async => await e.address == address))
      .flatMap((v) => v.sentMessagesStream)
      .cast<List<Tuple2<PendingTransaction, Transaction?>>?>()
      .onErrorReturn(null)
      .distinct((a, b) => listEquals(a, b));

  Stream<List<PendingTransaction>?> getExpiredMessagesStream(String address) => _tonWalletsSubject
      .asyncMap((e) async => e.asyncFirstWhere((e) async => await e.address == address))
      .flatMap((v) => v.expiredMessagesStream)
      .cast<List<PendingTransaction>?>()
      .onErrorReturn(null)
      .distinct((a, b) => listEquals(a, b));

  Future<UnsignedMessage> prepareDeploy(String address) async {
    final tonWallet = await _getTonWallet(address);

    final message = await tonWallet.prepareDeploy(kDefaultMessageExpiration);

    return message;
  }

  Future<UnsignedMessage> prepareDeployWithMultipleOwners({
    required String address,
    required List<String> custodians,
    required int reqConfirms,
  }) async {
    final tonWallet = await _getTonWallet(address);

    final message = await tonWallet.prepareDeployWithMultipleOwners(
      expiration: kDefaultMessageExpiration,
      custodians: custodians,
      reqConfirms: reqConfirms,
    );

    return message;
  }

  Future<UnsignedMessage> prepareTransfer({
    required String address,
    String? publicKey,
    required String destination,
    required String amount,
    String? body,
  }) async {
    final tonWallet = await _getTonWallet(address);

    final message = await tonWallet.prepareTransfer(
      publicKey: publicKey ?? await tonWallet.publicKey,
      destination: destination,
      amount: amount,
      body: body,
      expiration: kDefaultMessageExpiration,
    );

    return message;
  }

  Future<UnsignedMessage> prepareConfirmTransaction({
    required String address,
    required String publicKey,
    required String transactionId,
  }) async {
    final tonWallet = await _getTonWallet(address);

    final message = await tonWallet.prepareConfirmTransaction(
      publicKey: publicKey,
      transactionId: transactionId,
      expiration: kDefaultMessageExpiration,
    );

    return message;
  }

  Future<String> estimateFees({
    required String address,
    required UnsignedMessage message,
  }) async {
    final tonWallet = await _getTonWallet(address);

    final fees = await tonWallet.estimateFees(message);

    return fees;
  }

  Future<PendingTransaction> send({
    required String address,
    required String publicKey,
    required String password,
    required UnsignedMessage message,
  }) async {
    final tonWallet = await _getTonWallet(address);

    final signInput = _keystoreSource.keys.firstWhere((e) => e.publicKey == publicKey).signInput(password);

    final pendingTransaction = await tonWallet.send(
      keystore: _keystoreSource.keystore,
      message: message,
      signInput: signInput,
    );

    return pendingTransaction;
  }

  Future<void> refresh(String address) async {
    final tonWallet = await _getTonWallet(address);

    await tonWallet.refresh();
  }

  Future<void> preloadTransactions({
    required String address,
    required TransactionId from,
  }) async {
    final tonWallet = await _getTonWallet(address);

    await tonWallet.preloadTransactions(from);
  }

  Future<TonWallet> _getTonWallet(String address) => _tonWalletsSubject
      .asyncMap((e) async => e.asyncFirstWhereOrNull((e) async => await e.address == address))
      .whereType<TonWallet>()
      .first
      .timeout(
        kSubscriptionRefreshTimeout * 2,
        onTimeout: () => throw Exception('Ton wallet not found'),
      );

  Future<void> _currentAccountsStreamListener(Tuple2<List<AssetsList>, Transport> event) async {
    try {
      final accounts = event.item1;
      final transport = event.item2;

      final tonWalletAssets = accounts.map((e) => e.tonWallet);

      final tonWalletsForUnsubscription = await _tonWalletsSubject.value.asyncWhere(
        (e) async =>
            e.transport != transport || !await tonWalletAssets.asyncAny((el) async => el.address == await e.address),
      );

      for (final tonWalletForUnsubscription in tonWalletsForUnsubscription) {
        _tonWalletsSubject.add(_tonWalletsSubject.value.where((e) => e != tonWalletForUnsubscription).toList());

        tonWalletForUnsubscription.freePtr();
      }

      final tonWalletAssetsForSubscription = await tonWalletAssets.asyncWhere(
        (e) async => !await _tonWalletsSubject.value.asyncAny((el) async => await el.address == e.address),
      );

      for (final tonWalletAssetForSubscription in tonWalletAssetsForSubscription) {
        try {
          final tonWallet = await TonWallet.subscribe(
            transport: transport,
            workchain: kDefaultWorkchain,
            publicKey: tonWalletAssetForSubscription.publicKey,
            walletType: tonWalletAssetForSubscription.contract,
          );

          _tonWalletsSubject.add([..._tonWalletsSubject.value, tonWallet]);
        } catch (err, st) {
          logger.e(err, err, st);
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

      final currentTonWallets = next.map((e) => e.tonWallet);
      final previousTonWallets = prev.map((e) => e.tonWallet);

      final removedTonWallets = [...previousTonWallets]
        ..removeWhere((e) => currentTonWallets.any((el) => el.address == e.address));

      for (final removedTonWallet in removedTonWallets) {
        await _hiveSource.removeTonWalletInfo(removedTonWallet.address);
        await _hiveSource.removeTonWalletTransactions(removedTonWallet.address);
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
