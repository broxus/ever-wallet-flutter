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
    _transportSource.transportStream
        .skip(1)
        .whereType<Transport>()
        .listen((event) => _lock.synchronized(() => _transportStreamListener()));

    _accountsStorageSource.currentAccountsStream
        .startWith(const [])
        .pairwise()
        .listen((event) => _lock.synchronized(() => _currentAccountsStreamListener(event)));

    _accountsStorageSource.accountsStream
        .skip(1)
        .startWith(const [])
        .pairwise()
        .listen((event) => _lock.synchronized(() => _accountsStreamListener(event)));
  }

  Stream<TonWalletInfo> getInfoStream(String address) => _tonWalletsSubject
      .asyncMap((e) async => e.asyncFirstWhereOrNull((e) async => await e.address == address))
      .whereType<TonWallet>()
      .flatMap((v) => v.onStateChangedStream.map((e) => v))
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

          await _hiveSource.saveTonWalletInfo(tonWalletInfo);

          return tonWalletInfo;
        },
      )
      .whereType<TonWalletInfo?>()
      .startWith(_hiveSource.getTonWalletInfo(address))
      .whereType<TonWalletInfo>();

  Stream<ContractState> getStateChangesStream(String address) => _tonWalletsSubject
      .asyncMap((e) async => e.asyncFirstWhereOrNull((e) async => await e.address == address))
      .whereType<TonWallet>()
      .flatMap((v) => v.onStateChangedStream)
      .map((e) => e.newState);

  Stream<List<PendingTransaction>> getPendingTransactionsStream(String address) => _tonWalletsSubject
      .asyncMap((e) async => e.asyncFirstWhereOrNull((e) async => await e.address == address))
      .whereType<TonWallet>()
      .flatMap((v) => v.pendingTransactionsStream);

  Stream<List<MultisigPendingTransaction>> getUnconfirmedTransactionsStream(String address) => _tonWalletsSubject
      .asyncMap((e) async => e.asyncFirstWhereOrNull((e) async => await e.address == address))
      .whereType<TonWallet>()
      .flatMap((v) => v.unconfirmedTransactionsStream);

  Stream<List<TonWalletTransactionWithData>> getTransactionsStream(String address) => _tonWalletsSubject
      .asyncMap((e) async => e.asyncFirstWhereOrNull((e) async => await e.address == address))
      .whereType<TonWallet>()
      .flatMap((v) => v.onTransactionsFoundStream)
      .cast<OnTonWalletTransactionsFoundPayload?>()
      .startWith(null)
      .pairwise()
      .asyncMap(
        (e) async {
          final prev = e.first;
          final next = e.last;

          final transactions = [
            ...prev?.transactions ?? <TonWalletTransactionWithData>[],
            ...next?.transactions ?? <TonWalletTransactionWithData>[],
          ]..sort((a, b) => a.transaction.compareTo(b.transaction));

          await _hiveSource.saveTonWalletTransactions(
            address: address,
            transactions: transactions,
          );

          return transactions;
        },
      )
      .whereType<List<TonWalletTransactionWithData>?>()
      .startWith(_hiveSource.getTonWalletTransactions(address))
      .whereType<List<TonWalletTransactionWithData>>();

  Stream<List<Tuple2<PendingTransaction, Transaction?>>> getSentMessagesStream(String address) => _tonWalletsSubject
          .asyncMap((e) async => e.asyncFirstWhereOrNull((e) async => await e.address == address))
          .whereType<TonWallet>()
          .flatMap((v) => v.onMessageSentStream)
          .cast<OnMessageSentPayload?>()
          .startWith(null)
          .pairwise()
          .asyncMap(
        (e) async {
          final prev = e.first;
          final next = e.last;

          final messages = [
            if (prev != null) Tuple2(prev.pendingTransaction, prev.transaction),
            if (next != null) Tuple2(next.pendingTransaction, next.transaction),
          ].whereNotNull().toList()
            ..sort((a, b) => a.item1.compareTo(b.item1));

          return messages;
        },
      );

  Stream<List<PendingTransaction>> getExpiredMessagesStream(String address) => _tonWalletsSubject
          .asyncMap((e) async => e.asyncFirstWhereOrNull((e) async => await e.address == address))
          .whereType<TonWallet>()
          .flatMap((v) => v.onMessageExpiredStream)
          .cast<OnMessageExpiredPayload?>()
          .startWith(null)
          .pairwise()
          .asyncMap(
        (e) async {
          final prev = e.first;
          final next = e.last;

          final transactions = [
            prev?.pendingTransaction,
            next?.pendingTransaction,
          ].whereNotNull().toList()
            ..sort((a, b) => a.compareTo(b));

          return transactions;
        },
      );

  Future<UnsignedMessage> prepareDeploy(String address) async {
    final tonWallet = await _tonWalletsSubject.value.asyncFirstWhereOrNull((e) async => await e.address == address);

    if (tonWallet == null) throw Exception('Ton wallet not found');

    final message = await tonWallet.prepareDeploy(kDefaultMessageExpiration);

    return message;
  }

  Future<UnsignedMessage> prepareDeployWithMultipleOwners({
    required String address,
    required List<String> custodians,
    required int reqConfirms,
  }) async {
    final tonWallet = await _tonWalletsSubject.value.asyncFirstWhereOrNull((e) async => await e.address == address);

    if (tonWallet == null) throw Exception('Ton wallet not found');

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
    final tonWallet = await _tonWalletsSubject.value.asyncFirstWhereOrNull((e) async => await e.address == address);

    if (tonWallet == null) throw Exception('Ton wallet not found');

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
    final tonWallet = await _tonWalletsSubject.value.asyncFirstWhereOrNull((e) async => await e.address == address);

    if (tonWallet == null) throw Exception('Ton wallet not found');

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
    final tonWallet = await _tonWalletsSubject.value.asyncFirstWhereOrNull((e) async => await e.address == address);

    if (tonWallet == null) throw Exception('Ton wallet not found');

    final fees = await tonWallet.estimateFees(message);

    return fees;
  }

  Future<PendingTransaction> send({
    required String address,
    required String publicKey,
    required String password,
    required UnsignedMessage message,
  }) async {
    final tonWallet = await _tonWalletsSubject.value.asyncFirstWhereOrNull((e) async => await e.address == address);

    if (tonWallet == null) throw Exception('Ton wallet not found');

    final signInput = _keystoreSource.keys.firstWhere((e) => e.publicKey == publicKey).getSignInput(password);

    final pendingTransaction = await tonWallet.send(
      keystore: _keystoreSource.keystore,
      message: message,
      signInput: signInput,
    );

    return pendingTransaction;
  }

  Future<void> refresh(String address) async {
    final tonWallet = await _tonWalletsSubject.value.asyncFirstWhereOrNull((e) async => await e.address == address);

    if (tonWallet == null) throw Exception('Ton wallet not found');

    await tonWallet.refresh();
  }

  Future<void> preloadTransactions({
    required String address,
    required TransactionId from,
  }) async {
    final tonWallet = await _tonWalletsSubject.value.asyncFirstWhereOrNull((e) async => await e.address == address);

    if (tonWallet == null) throw Exception('Ton wallet not found');

    await tonWallet.preloadTransactions(from);
  }

  Future<TonWallet> _subscribe(String address) async {
    var tonWallet = await _tonWalletsSubject.value.asyncFirstWhereOrNull((e) async => await e.address == address);

    if (tonWallet != null) return tonWallet;

    final transport = _transportSource.transport;

    if (transport == null) throw Exception('Transport unavailable');

    tonWallet = await TonWallet.subscribeByAddress(
      transport: transport,
      address: address,
    );

    _tonWalletsSubject.add([..._tonWalletsSubject.value, tonWallet]);

    return tonWallet;
  }

  Future<void> _unsubscribe(String address) async {
    final tonWallet = await _tonWalletsSubject.value.asyncFirstWhereOrNull((e) async => await e.address == address);

    if (tonWallet == null) return;

    final tonWallets = _tonWalletsSubject.value.where((e) => e != tonWallet).toList();

    _tonWalletsSubject.add(tonWallets);

    await tonWallet.freePtr();
  }

  Future<void> _clear() async {
    final tonWallets = [..._tonWalletsSubject.value];

    _tonWalletsSubject.add([]);

    for (final tonWallet in tonWallets) {
      await tonWallet.freePtr();
    }
  }

  Future<void> _transportStreamListener() async {
    try {
      final tonWallets = await Future.wait(_tonWalletsSubject.value.map((e) => e.address));

      await _clear();

      for (final tonWallet in tonWallets) {
        await _subscribe(tonWallet);
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<void> _currentAccountsStreamListener(Iterable<List<AssetsList>> event) async {
    try {
      final prev = event.first;
      final next = event.last;

      final currentTonWallets = next.map((e) => e.tonWallet);
      final previousTonWallets = prev.map((e) => e.tonWallet);

      final addedTonWallets = [...currentTonWallets]
        ..removeWhere((e) => previousTonWallets.any((el) => el.address == e.address));
      final removedTonWallets = [...previousTonWallets]
        ..removeWhere((e) => currentTonWallets.any((el) => el.address == e.address));

      for (final addedTonWallet in addedTonWallets) {
        await _subscribe(addedTonWallet.address);
      }

      for (final removedTonWallet in removedTonWallets) {
        await _unsubscribe(removedTonWallet.address);
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
