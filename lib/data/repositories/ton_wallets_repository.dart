import 'dart:async';

import 'package:collection/collection.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/models/ton_wallet_info.dart';
import 'package:ever_wallet/data/sources/local/current_accounts_source.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/data/sources/remote/transport_source.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tuple/tuple.dart';

class TonWalletsRepository {
  final _lock = Lock();
  final AccountsStorage _accountsStorage;
  final CurrentAccountsSource _currentAccountsSource;
  final TransportSource _transportSource;
  final HiveSource _hiveSource;
  final _tonWalletsSubject = BehaviorSubject<List<TonWallet>>.seeded([]);
  late final StreamSubscription _currentAccountsStreamSubscription;
  late final StreamSubscription _accountsStreamSubscription;

  TonWalletsRepository(
    this._accountsStorage,
    this._currentAccountsSource,
    this._transportSource,
    this._hiveSource,
  ) {
    _currentAccountsStreamSubscription =
        Rx.combineLatest3<List<AssetsList>, Transport, void, Tuple2<List<AssetsList>, Transport>>(
      _currentAccountsSource.currentAccountsStream,
      _transportSource.transportStream,
      Stream<void>.periodic(kSubscriptionRefreshTimeout).startWith(null),
      (a, b, c) => Tuple2(a, b),
    ).listen((event) => _lock.synchronized(() => _currentAccountsStreamListener(event)));

    _accountsStreamSubscription = _accountsStorage.entriesStream
        .skip(1)
        .startWith(const [])
        .pairwise()
        .listen((event) => _lock.synchronized(() => _accountsStreamListener(event)));
  }

  Future<TonWalletInfo> getInfo(String address) async {
    final tonWallet = await _getTonWallet(address);

    final tonWalletInfo = TonWalletInfo(
      workchain: tonWallet.workchain,
      address: tonWallet.address,
      publicKey: tonWallet.publicKey,
      walletType: tonWallet.walletType,
      contractState: await tonWallet.contractState,
      details: tonWallet.details,
      custodians: await tonWallet.custodians,
    );

    await _hiveSource.saveTonWalletInfo(
      address: address,
      group: tonWallet.transport.group,
      info: tonWalletInfo,
    );

    return tonWalletInfo;
  }

  Stream<TonWalletInfo?> getInfoStream(String address) => _tonWalletsSubject
      .map((e) => e.firstWhere((e) => e.address == address))
      .flatMap(
        (v) => v.onStateChangedStream
            .map((e) => e.newState)
            .cast<ContractState?>()
            .startWith(null)
            .map((e) => v),
      )
      .asyncMap(
        (e) async {
          final tonWalletInfo = TonWalletInfo(
            workchain: e.workchain,
            address: e.address,
            publicKey: e.publicKey,
            walletType: e.walletType,
            contractState: await e.contractState,
            details: e.details,
            custodians: await e.custodians,
          );

          await _hiveSource.saveTonWalletInfo(
            address: address,
            group: e.transport.group,
            info: tonWalletInfo,
          );

          return tonWalletInfo;
        },
      )
      .cast<TonWalletInfo?>()
      .onErrorReturn(null)
      .distinct();

  Stream<List<TonWalletTransactionWithData>?> getTransactionsStream(String address) =>
      _tonWalletsSubject
          .map((e) => e.firstWhere((e) => e.address == address))
          .flatMap(
            (v) => v.transactionsStream.asyncMap(
              (e) async {
                final group = v.transport.group;

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

  Stream<List<PendingTransaction>?> getPendingTransactionsStream(String address) =>
      _tonWalletsSubject
          .map((e) => e.firstWhere((e) => e.address == address))
          .flatMap((v) => v.pendingTransactionsStream)
          .cast<List<PendingTransaction>?>()
          .onErrorReturn(null)
          .distinct((a, b) => listEquals(a, b));

  Stream<List<MultisigPendingTransaction>?> getUnconfirmedTransactionsStream(String address) =>
      _tonWalletsSubject
          .map((e) => e.firstWhere((e) => e.address == address))
          .flatMap((v) => v.unconfirmedTransactionsStream)
          .cast<List<MultisigPendingTransaction>?>()
          .onErrorReturn(null)
          .distinct((a, b) => listEquals(a, b));

  Stream<List<PendingTransaction>?> getExpiredMessagesStream(String address) => _tonWalletsSubject
      .map((e) => e.firstWhere((e) => e.address == address))
      .flatMap((v) => v.expiredTransactionsStream)
      .cast<List<PendingTransaction>?>()
      .onErrorReturn(null)
      .distinct((a, b) => listEquals(a, b));

  Future<UnsignedMessage> prepareDeploy(String address) async {
    final tonWallet = await _getTonWallet(address);

    final unsignedMessage = await tonWallet.prepareDeploy(kDefaultMessageExpiration);

    return unsignedMessage;
  }

  Future<UnsignedMessage> prepareDeployWithMultipleOwners({
    required String address,
    required List<String> custodians,
    required int reqConfirms,
  }) async {
    final tonWallet = await _getTonWallet(address);

    final unsignedMessage = await tonWallet.prepareDeployWithMultipleOwners(
      expiration: kDefaultMessageExpiration,
      custodians: custodians,
      reqConfirms: reqConfirms,
    );

    return unsignedMessage;
  }

  Future<UnsignedMessage> prepareTransfer({
    required String address,
    String? publicKey,
    required String destination,
    required String amount,
    String? body,
  }) async {
    final tonWallet = await _getTonWallet(address);

    final contractState = await tonWallet.transport.getContractState(address);

    final unsignedMessage = await tonWallet.prepareTransfer(
      contractState: contractState,
      publicKey: publicKey ?? tonWallet.publicKey,
      destination: destination,
      amount: amount,
      body: body,
      bounce: kMessageBounce,
      expiration: kDefaultMessageExpiration,
    );

    return unsignedMessage;
  }

  Future<UnsignedMessage> prepareConfirmTransaction({
    required String address,
    required String publicKey,
    required String transactionId,
  }) async {
    final tonWallet = await _getTonWallet(address);

    final contractState = await tonWallet.transport.getContractState(address);

    final unsignedMessage = await tonWallet.prepareConfirmTransaction(
      contractState: contractState,
      publicKey: publicKey,
      transactionId: transactionId,
      expiration: kDefaultMessageExpiration,
    );

    return unsignedMessage;
  }

  Future<String> estimateFees({
    required String address,
    required SignedMessage signedMessage,
  }) async {
    final tonWallet = await _getTonWallet(address);

    final fees = await tonWallet.estimateFees(signedMessage);

    return fees;
  }

  Future<Transaction?> send({
    required String address,
    required SignedMessage signedMessage,
  }) async {
    final tonWallet = await _getTonWallet(address);

    final transaction = await tonWallet.send(signedMessage);

    return transaction;
  }

  Future<void> refresh(String address) async {
    final tonWallet = await _getTonWallet(address);

    await tonWallet.refresh();
  }

  Future<void> preloadTransactions({
    required String address,
    required String fromLt,
  }) async {
    final tonWallet = await _getTonWallet(address);

    await tonWallet.preloadTransactions(fromLt);
  }

  Future<void> dispose() async {
    await _currentAccountsStreamSubscription.cancel();
    await _accountsStreamSubscription.cancel();

    await _tonWalletsSubject.close();
  }

  Future<TonWallet> _getTonWallet(String address) => _tonWalletsSubject
      .map((e) => e.firstWhereOrNull((e) => e.address == address))
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

      final tonWalletsForUnsubscription = _tonWalletsSubject.value.where(
        (e) => e.transport != transport || !tonWalletAssets.any((el) => el.address == e.address),
      );

      for (final tonWalletForUnsubscription in tonWalletsForUnsubscription) {
        _tonWalletsSubject
            .add(_tonWalletsSubject.value.where((e) => e != tonWalletForUnsubscription).toList());

        tonWalletForUnsubscription.dispose();
      }

      final tonWalletAssetsForSubscription = tonWalletAssets.where(
        (e) => !_tonWalletsSubject.value.any((el) => el.address == e.address),
      );

      for (final tonWalletAssetForSubscription in tonWalletAssetsForSubscription) {
        try {
          final tonWallet = await TonWallet.subscribe(
            transport: transport,
            workchain: kDefaultWorkchain,
            publicKey: tonWalletAssetForSubscription.publicKey,
            contract: tonWalletAssetForSubscription.contract,
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
