import 'dart:async';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/models/pending_transaction_with_additional_info.dart';
import 'package:ever_wallet/data/models/signed_message_with_additional_info.dart';
import 'package:ever_wallet/data/models/ton_wallet_expired_transaction.dart';
import 'package:ever_wallet/data/models/ton_wallet_multisig_expired_transaction.dart';
import 'package:ever_wallet/data/models/ton_wallet_multisig_ordinary_transaction.dart';
import 'package:ever_wallet/data/models/ton_wallet_multisig_pending_transaction.dart';
import 'package:ever_wallet/data/models/ton_wallet_ordinary_transaction.dart';
import 'package:ever_wallet/data/models/ton_wallet_pending_subscription_collection.dart';
import 'package:ever_wallet/data/models/ton_wallet_pending_transaction.dart';
import 'package:ever_wallet/data/models/ton_wallet_subscription.dart';
import 'package:ever_wallet/data/models/unsigned_message_with_additional_info.dart';
import 'package:ever_wallet/data/sources/local/app_lifecycle_state_source.dart';
import 'package:ever_wallet/data/sources/local/current_accounts_source.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/data/sources/local/sqlite/sqlite_database.dart' as sql;
import 'package:ever_wallet/data/sources/remote/transport_source.dart';
import 'package:ever_wallet/data/utils.dart';
import 'package:ever_wallet/logger.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tuple/tuple.dart';

class TonWalletsRepository {
  final _lock = Lock();
  final Map<TonWalletPendingSubscriptionCollection, Completer<TonWalletSubscription>>
      _pendingTonWalletSubscriptions = {};
  final Keystore _keystore;
  final sql.SqliteDatabase _sqliteDatabase;
  final HiveSource _hiveSource;
  final TransportSource _transportSource;
  final CurrentAccountsSource _currentAccountsSource;
  final AppLifecycleStateSource _appLifecycleStateSource;
  final _tonWalletsSubject =
      BehaviorSubject<Map<String, Completer<TonWalletSubscription>>>.seeded({});
  late final Timer _pollingTimer;
  late final StreamSubscription _currentAccountsStreamSubscription;
  late final StreamSubscription _transportStreamSubscription;

  TonWalletsRepository({
    required Keystore keystore,
    required sql.SqliteDatabase sqliteDatabase,
    required HiveSource hiveSource,
    required TransportSource transportSource,
    required CurrentAccountsSource currentAccountsSource,
    required AppLifecycleStateSource appLifecycleStateSource,
  })  : _keystore = keystore,
        _sqliteDatabase = sqliteDatabase,
        _hiveSource = hiveSource,
        _transportSource = transportSource,
        _currentAccountsSource = currentAccountsSource,
        _appLifecycleStateSource = appLifecycleStateSource {
    _pollingTimer = Timer.periodic(kSubscriptionRefreshTimeout, _pollingTimerCallback);

    _currentAccountsStreamSubscription = _currentAccountsSource.currentAccountsStream
        .listen((e) => _lock.synchronized(() => _currentAccountsStreamListener(e)));

    _transportStreamSubscription = _transportSource.transportStream
        .listen((e) => _lock.synchronized(() => _transportStreamListener(e)));
  }

  Stream<List<TonWalletOrdinaryTransaction>> ordinaryTransactionsStream(String address) =>
      _tonWalletsSubject.map((e) => e[address]).whereNotNull().flatMap(
            (e) => e.future.asStream().flatMap(
                  (e) => _sqliteDatabase.tonWalletTransactionsDao
                      .transactions(
                        networkId: e.tonWallet.transport.networkId,
                        group: e.tonWallet.transport.group,
                        address: e.tonWallet.address,
                      )
                      .map(
                        (el) => _mapOrdinaryTransactions(tonWallet: e.tonWallet, transactions: el),
                      ),
                ),
          );

  Stream<List<TonWalletPendingTransaction>> pendingTransactionsStream(String address) =>
      _tonWalletsSubject.map((e) => e[address]).whereNotNull().flatMap(
            (e) => e.future.asStream().flatMap(
                  (e) => _sqliteDatabase.tonWalletPendingTransactionsDao
                      .transactions(
                        networkId: e.tonWallet.transport.networkId,
                        group: e.tonWallet.transport.group,
                        address: e.tonWallet.address,
                      )
                      .map(
                        (el) => _mapPendingTransactions(
                          tonWallet: e.tonWallet,
                          pendingTransactions: el,
                        ),
                      ),
                ),
          );

  Stream<List<TonWalletExpiredTransaction>> expiredTransactionsStream(String address) =>
      _tonWalletsSubject.map((e) => e[address]).whereNotNull().flatMap(
            (e) => e.future.asStream().flatMap(
                  (e) => _sqliteDatabase.tonWalletExpiredTransactionsDao
                      .transactions(
                        networkId: e.tonWallet.transport.networkId,
                        group: e.tonWallet.transport.group,
                        address: e.tonWallet.address,
                      )
                      .map(
                        (el) => _mapExpiredTransactions(
                          tonWallet: e.tonWallet,
                          expiredTransactions: el,
                        ),
                      ),
                ),
          );

  Stream<List<TonWalletMultisigOrdinaryTransaction>> multisigOrdinaryTransactionsStream(
    String address,
  ) =>
      _tonWalletsSubject.map((e) => e[address]).whereNotNull().flatMap(
            (e) => e.future.asStream().flatMap(
                  (e) => Rx.combineLatest2<
                      List<TransactionWithData<TransactionAdditionalInfo?>>,
                      List<MultisigPendingTransaction>,
                      Tuple2<List<TransactionWithData<TransactionAdditionalInfo?>>,
                          List<MultisigPendingTransaction>>>(
                    _sqliteDatabase.tonWalletTransactionsDao.transactions(
                      networkId: e.tonWallet.transport.networkId,
                      group: e.tonWallet.transport.group,
                      address: e.tonWallet.address,
                    ),
                    e.tonWallet.unconfirmedTransactionsStream,
                    (a, b) => Tuple2(a, b),
                  ).map(
                    (el) => _mapMultisigOrdinaryTransactions(
                      tonWallet: e.tonWallet,
                      transactions: el.item1,
                      multisigPendingTransactions: el.item2,
                    ),
                  ),
                ),
          );

  Stream<List<TonWalletMultisigPendingTransaction>> multisigPendingTransactionsStream(
    String address,
  ) =>
      _tonWalletsSubject.map((e) => e[address]).whereNotNull().flatMap(
            (e) => e.future.asStream().flatMap(
                  (e) => Rx.combineLatest2<
                      List<TransactionWithData<TransactionAdditionalInfo?>>,
                      List<MultisigPendingTransaction>,
                      Tuple2<List<TransactionWithData<TransactionAdditionalInfo?>>,
                          List<MultisigPendingTransaction>>>(
                    _sqliteDatabase.tonWalletTransactionsDao.transactions(
                      networkId: e.tonWallet.transport.networkId,
                      group: e.tonWallet.transport.group,
                      address: e.tonWallet.address,
                    ),
                    e.tonWallet.unconfirmedTransactionsStream,
                    (a, b) => Tuple2(a, b),
                  ).map(
                    (el) => _mapMultisigPendingTransactions(
                      tonWallet: e.tonWallet,
                      transactions: el.item1,
                      multisigPendingTransactions: el.item2,
                    ),
                  ),
                ),
          );

  Stream<List<TonWalletMultisigExpiredTransaction>> multisigExpiredTransactionsStream(
    String address,
  ) =>
      _tonWalletsSubject.map((e) => e[address]).whereNotNull().flatMap(
            (e) => e.future.asStream().flatMap(
                  (e) => Rx.combineLatest2<
                      List<TransactionWithData<TransactionAdditionalInfo?>>,
                      List<MultisigPendingTransaction>,
                      Tuple2<List<TransactionWithData<TransactionAdditionalInfo?>>,
                          List<MultisigPendingTransaction>>>(
                    _sqliteDatabase.tonWalletTransactionsDao.transactions(
                      networkId: e.tonWallet.transport.networkId,
                      group: e.tonWallet.transport.group,
                      address: e.tonWallet.address,
                    ),
                    e.tonWallet.unconfirmedTransactionsStream,
                    (a, b) => Tuple2(a, b),
                  ).map(
                    (el) => _mapMultisigExpiredTransactions(
                      tonWallet: e.tonWallet,
                      transactions: el.item1,
                      multisigPendingTransactions: el.item2,
                    ),
                  ),
                ),
          );

  Stream<ContractState> contractStateStream(String address) =>
      _tonWallet(address).flatMap((v) => v.onStateChangedStream.startWith(v.contractState));

  Future<ContractState> contractState(String address) => contractStateStream(address).first;

  Stream<TonWalletDetails> detailsStream(String address) => _tonWallet(address)
      .flatMap((v) => v.onStateChangedStream.map((_) => v.details).startWith(v.details));

  Future<TonWalletDetails> details(String address) => detailsStream(address).first;

  Stream<List<String>?> custodiansStream(String address) => _tonWallet(address)
      .flatMap((v) => v.onStateChangedStream.map((_) => v.custodians).startWith(v.custodians));

  Future<List<String>?> custodians(String address) => custodiansStream(address).first;

  Stream<List<String>?> localCustodiansStream(String address) => _tonWallet(address).flatMap(
        (v) => v.onStateChangedStream.map((_) => v.custodians).startWith(v.custodians).map((e) {
          final custodians = e;

          if (custodians == null) return null;

          final localCustodians = _keystore.entries
              .map((e) => e.publicKey)
              .where((e) => custodians.any((el) => el == e))
              .toList();

          final initiatorKey = localCustodians.firstWhereOrNull((e) => e == _hiveSource.currentKey);

          final sortedLocalCustodians = [
            if (initiatorKey != null) initiatorKey,
            ...localCustodians.where((e) => e != initiatorKey),
          ];

          return sortedLocalCustodians;
        }),
      );

  Future<List<String>?> localCustodians(String address) => localCustodiansStream(address).first;

  Future<UnsignedMessageWithAdditionalInfo> prepareDeploy(String address) async {
    final tonWallet = await getTonWalletStream(address).first;

    final unsignedMessage = await tonWallet.prepareDeploy(kDefaultMessageExpiration);

    final unsignedMessageWithAdditionalInfo =
        UnsignedMessageWithAdditionalInfo(message: unsignedMessage);

    return unsignedMessageWithAdditionalInfo;
  }

  Future<UnsignedMessageWithAdditionalInfo> prepareDeployWithMultipleOwners({
    required String address,
    required List<String> custodians,
    required int reqConfirms,
  }) async {
    final tonWallet = await getTonWalletStream(address).first;

    final unsignedMessage = await tonWallet.prepareDeployWithMultipleOwners(
      expiration: kDefaultMessageExpiration,
      custodians: custodians,
      reqConfirms: reqConfirms,
    );

    final unsignedMessageWithAdditionalInfo =
        UnsignedMessageWithAdditionalInfo(message: unsignedMessage);

    return unsignedMessageWithAdditionalInfo;
  }

  Future<UnsignedMessageWithAdditionalInfo> prepareTransfer({
    required String address,
    required String destination,
    required String amount,
    String? publicKey,
    String? body,
    required bool bounce,
  }) async {
    final tonWallet = await getTonWalletStream(address).first;

    final contractState = await tonWallet.transport.getContractState(address);

    final unsignedMessage = await tonWallet.prepareTransfer(
      contractState: contractState,
      publicKey: publicKey ?? tonWallet.publicKey,
      destination: destination,
      amount: amount,
      bounce: bounce,
      expiration: kDefaultMessageExpiration,
    );

    final unsignedMessageWithAdditionalInfo = UnsignedMessageWithAdditionalInfo(
      message: unsignedMessage,
      dst: destination,
      amount: amount,
    );

    return unsignedMessageWithAdditionalInfo;
  }

  Future<UnsignedMessageWithAdditionalInfo> prepareConfirmTransaction({
    required String address,
    required String publicKey,
    required String transactionId,
  }) async {
    final tonWallet = await getTonWalletStream(address).first;

    final contractState = await tonWallet.transport.getContractState(address);

    final unsignedMessage = await tonWallet.prepareConfirmTransaction(
      contractState: contractState,
      publicKey: publicKey,
      transactionId: transactionId,
      expiration: kDefaultMessageExpiration,
    );

    final unsignedMessageWithAdditionalInfo =
        UnsignedMessageWithAdditionalInfo(message: unsignedMessage);

    return unsignedMessageWithAdditionalInfo;
  }

  Future<String> estimateFees({
    required String address,
    required UnsignedMessageWithAdditionalInfo unsignedMessageWithAdditionalInfo,
  }) async {
    final tonWallet = await getTonWalletStream(address).first;

    final unsignedMessage = unsignedMessageWithAdditionalInfo.message;

    await unsignedMessage.refreshTimeout();

    final signedMessage = await unsignedMessage.sign(fakeSignature());

    final fees = await tonWallet.estimateFees(signedMessage);

    return fees;
  }

  Future<Transaction> send({
    required String address,
    required SignedMessageWithAdditionalInfo signedMessageWithAdditionalInfo,
  }) async {
    final tonWallet = await getTonWalletStream(address).first;

    final transport = tonWallet.transport;
    final signedMessage = signedMessageWithAdditionalInfo.message;

    if (transport is GqlTransport) {
      var currentBlockId = await transport.getLatestBlockId(address);

      final pendingTransaction = await tonWallet.send(signedMessage);

      final pendingTransactionWithAdditionalInfo = PendingTransactionWithAdditionalInfo(
        transaction: pendingTransaction,
        createdAt: DateTime.now().secondsSinceEpoch,
        dst: signedMessageWithAdditionalInfo.dst,
        amount: signedMessageWithAdditionalInfo.amount,
      );

      await _sqliteDatabase.tonWalletPendingTransactionsDao.insertTransaction(
        networkId: tonWallet.transport.networkId,
        group: tonWallet.transport.group,
        address: tonWallet.address,
        transaction: pendingTransactionWithAdditionalInfo,
      );

      final completer = Completer<Transaction>();

      tonWallet.onMessageSentStream
          .firstWhere((e) => e.item1 == pendingTransaction)
          .timeout(pendingTransaction.expireAt.toTimeout())
          .then((v) => completer.complete(v.item2))
          .onError((err, st) => completer.completeError(err!));

      () async {
        while (tonWallet.pollingMethod == PollingMethod.reliable) {
          try {
            final nextBlockId = await transport.waitForNextBlockId(
              currentBlockId: currentBlockId,
              address: address,
              timeout: kNextBlockTimeout.inSeconds,
            );

            final block = await transport.getBlock(nextBlockId);

            await tonWallet.handleBlock(block);

            currentBlockId = nextBlockId;
          } catch (err, st) {
            logger.e('Reliable polling error', err, st);
            break;
          }
        }
      }();

      return completer.future;
    } else if (transport is JrpcTransport) {
      final pendingTransaction = await tonWallet.send(signedMessage);

      final pendingTransactionWithAdditionalInfo = PendingTransactionWithAdditionalInfo(
        transaction: pendingTransaction,
        createdAt: DateTime.now().secondsSinceEpoch,
        dst: signedMessageWithAdditionalInfo.dst,
        amount: signedMessageWithAdditionalInfo.amount,
      );

      await _sqliteDatabase.tonWalletPendingTransactionsDao.insertTransaction(
        networkId: tonWallet.transport.networkId,
        group: tonWallet.transport.group,
        address: tonWallet.address,
        transaction: pendingTransactionWithAdditionalInfo,
      );

      final completer = Completer<Transaction>();

      tonWallet.onMessageSentStream
          .firstWhere((e) => e.item1 == pendingTransaction)
          .timeout(pendingTransaction.expireAt.toTimeout())
          .then((v) => completer.complete(v.item2))
          .onError((err, st) => completer.completeError(err!));

      () async {
        while (tonWallet.pollingMethod == PollingMethod.reliable) {
          try {
            await tonWallet.refresh();
            await Future<void>.delayed(kIntensivePollingInterval);
          } catch (err, st) {
            logger.e('Reliable polling error', err, st);
            break;
          }
        }
      }();

      return completer.future;
    } else {
      throw UnsupportedError('Invalid transport');
    }
  }

  Future<void> refresh(String address) async {
    final tonWallet = await getTonWalletStream(address).first;

    await tonWallet.refresh();
  }

  Future<void> preloadTransactions({
    required String address,
    required String fromLt,
  }) async {
    final tonWallet = await getTonWalletStream(address).first;

    await tonWallet.preloadTransactions(fromLt);
  }

  /// Update subscriptions by adding a new one with [address] and return it
  Future<void> updateSubscription(String address) => _lock.synchronized(() async {
        final transport = _transportSource.transport;
        final subscriptions = {..._tonWalletsSubject.value};

        final tonWallet = _currentAccountsSource.currentAccounts
            .map((e) => e.tonWallet)
            .firstWhere((e) => e.address == address);

        await subscriptions[address]?.future.then((v) => v.dispose());

        final newCompleter = _subscribe(
          tonWalletAsset: tonWallet,
          transport: transport,
        ).wrapInCompleter();
        _pendingTonWalletSubscriptions[TonWalletPendingSubscriptionCollection(
          asset: tonWallet,
          transportCollection: transport.toEquatableCollection(),
        )] = newCompleter;

        subscriptions[address] = newCompleter;

        _tonWalletsSubject.add(subscriptions);
      });

  Future<void> dispose() async {
    _pollingTimer.cancel();

    await _currentAccountsStreamSubscription.cancel();
    await _transportStreamSubscription.cancel();

    await _tonWalletsSubject.close();

    for (final tonWallet in _tonWalletsSubject.value.values) {
      tonWallet.future.then((v) => v.dispose()).ignore();
    }
  }

  void _pollingTimerCallback(Timer timer) {
    final appLifecycleState = _appLifecycleStateSource.appLifecycleState;
    final appIsActive = appLifecycleState == AppLifecycleState.resumed ||
        appLifecycleState == AppLifecycleState.inactive;

    if (appIsActive) {
      for (final tonWallet in _tonWalletsSubject.value.values) {
        if (tonWallet.isCompleted) {
          tonWallet.future.then((v) async {
            if (v.tonWallet.pollingMethod == PollingMethod.manual) await v.tonWallet.refresh();
          }).ignore();
        }
      }
    }
  }

  void _currentAccountsStreamListener(List<AssetsList> event) {
    try {
      final tonWallets = event.map((e) => e.tonWallet);

      final transport = _transportSource.transport;
      final subscriptions = {..._tonWalletsSubject.value};

      final tonWalletsForUnSubscription = subscriptions.keys.where(
        (e) => !tonWallets.any((el) => el.address == e),
      );

      for (final address in tonWalletsForUnSubscription) {
        subscriptions.remove(address)!.future.then((v) => v.dispose()).ignore();
        final pendedKey = _pendingTonWalletSubscriptions.keys
            .firstWhereOrNull((key) => key.asset.address == address);
        if (pendedKey != null) {
          _pendingTonWalletSubscriptions.remove(pendedKey);
        }
      }

      final tonWalletsForSubscription = tonWallets.where(
        (e) => !subscriptions.keys.any((el) => el == e.address),
      );

      for (final e in tonWalletsForSubscription) {
        final completer = _subscribe(
          tonWalletAsset: e,
          transport: transport,
        ).wrapInCompleter();
        _pendingTonWalletSubscriptions[TonWalletPendingSubscriptionCollection(
          asset: e,
          transportCollection: transport.toEquatableCollection(),
        )] = completer;
        subscriptions[e.address] = completer;
      }
      _tonWalletsSubject.add({...subscriptions});
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  void _transportStreamListener(Transport event) {
    try {
      final transport = event;

      final tonWallets = _currentAccountsSource.currentAccounts.map((e) => e.tonWallet);

      /// contains assets where transport is different to new one
      final assetsToRemove = tonWallets.where((asset) {
        final pendingKey = TonWalletPendingSubscriptionCollection(
          asset: asset,
          transportCollection: transport.toEquatableCollection(),
        );
        final pendedEntry =
            _pendingTonWalletSubscriptions.entries.where((e) => e.key == pendingKey).firstOrNull;
        if (pendedEntry != null &&
            pendedEntry.key.isSameTransport(transport.toEquatableCollection())) {
          return false;
        }
        return true;
      });

      /// Unsubscribe
      for (final key in assetsToRemove) {
        _tonWalletsSubject.value[key.address]!.future.then((v) => v.dispose()).ignore();
        _pendingTonWalletSubscriptions.remove(
          TonWalletPendingSubscriptionCollection(asset: key, transportCollection: []),
        );
      }

      final subscriptions = <String, Completer<TonWalletSubscription>>{};
      for (final e in tonWallets) {
        final completer = _subscribe(
          tonWalletAsset: e,
          transport: transport,
        ).wrapInCompleter();
        _pendingTonWalletSubscriptions[TonWalletPendingSubscriptionCollection(
          asset: e,
          transportCollection: transport.toEquatableCollection(),
        )] = completer;
        subscriptions[e.address] = completer;
      }
      _tonWalletsSubject.add(subscriptions);
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<TonWalletSubscription> _subscribe({
    required TonWalletAsset tonWalletAsset,
    required Transport transport,
  }) async {
    final pendingKey = TonWalletPendingSubscriptionCollection(
      asset: tonWalletAsset,
      transportCollection: transport.toEquatableCollection(),
    );
    final pendedEntry =
        _pendingTonWalletSubscriptions.entries.where((e) => e.key == pendingKey).firstOrNull;
    if (pendedEntry != null) {
      if (pendedEntry.key.isSameTransport(pendingKey.transportCollection)) {
        return pendedEntry.value.future;
      }
    }
    final tonWallet = await TonWallet.subscribe(
      transport: transport,
      workchain: tonWalletAsset.workchain,
      publicKey: tonWalletAsset.publicKey,
      contract: tonWalletAsset.contract,
    );

    final subscription = TonWalletSubscription.subscribe(
      tonWallet: tonWallet,
      onMessageSent: (e) async {
        await _sqliteDatabase.tonWalletPendingTransactionsDao.deleteTransaction(
          networkId: tonWallet.transport.networkId,
          group: tonWallet.transport.group,
          address: tonWallet.address,
          messageHash: e.item1.messageHash,
        );
      },
      onMessageExpired: (e) async {
        final expiredTransaction =
            await _sqliteDatabase.tonWalletPendingTransactionsDao.deleteTransaction(
          networkId: tonWallet.transport.networkId,
          group: tonWallet.transport.group,
          address: tonWallet.address,
          messageHash: e.messageHash,
        );

        await _sqliteDatabase.tonWalletExpiredTransactionsDao.insertTransaction(
          address: tonWallet.address,
          group: tonWallet.transport.group,
          networkId: tonWallet.transport.networkId,
          transaction: expiredTransaction,
        );
      },
      onStateChanged: (e) async {
        await _sqliteDatabase.tonWalletDetailsDao.updateContractState(
          address: tonWallet.address,
          group: tonWallet.transport.group,
          networkId: tonWallet.transport.networkId,
          contractState: e,
        );

        await _sqliteDatabase.tonWalletDetailsDao.updateDetails(
          address: tonWallet.address,
          group: tonWallet.transport.group,
          networkId: tonWallet.transport.networkId,
          details: tonWallet.details,
        );

        await _sqliteDatabase.tonWalletDetailsDao.updateCustodians(
          address: tonWallet.address,
          group: tonWallet.transport.group,
          networkId: tonWallet.transport.networkId,
          custodians: tonWallet.custodians,
        );
      },
      onTransactionsFound: (e) async {
        await _sqliteDatabase.tonWalletTransactionsDao.insertTransactions(
          address: tonWallet.address,
          group: tonWallet.transport.group,
          networkId: tonWallet.transport.networkId,
          transactions: e.item1,
        );
      },
    );

    return subscription;
  }

  Stream<TonWallet> _tonWallet(String address) => getTonWalletStream(address);

  Stream<TonWallet> getTonWalletStream(String address) => _tonWalletsSubject.stream
      .where((v) => v[address] != null)
      .flatMap((value) => value[address]!.future.then((v) => v.tonWallet).asStream());

  List<TonWalletOrdinaryTransaction> _mapOrdinaryTransactions({
    required TonWallet tonWallet,
    required List<TransactionWithData<TransactionAdditionalInfo?>> transactions,
  }) =>
      transactions.where((e) => !e.isMultisigTransaction).map(
        (e) {
          final lt = e.transaction.id.lt;

          final prevTransactionLt = e.transaction.prevTransactionId?.lt;

          final msgSender = e.transaction.inMessage.src;

          final dataSender = e.data?.maybeWhen(
            walletInteraction: (data) => data.knownPayload?.maybeWhen(
              tokenSwapBack: (data) => data.callbackAddress,
              orElse: () => null,
            ),
            orElse: () => null,
          );

          final sender = dataSender ?? msgSender;

          final msgRecipient = e.transaction.outMessages.firstOrNull?.dst;

          final dataRecipient = e.data?.maybeWhen(
            walletInteraction: (data) =>
                data.knownPayload?.maybeWhen(
                  tokenOutgoingTransfer: (data) => data.to.data,
                  orElse: () => null,
                ) ??
                data.method.maybeWhen(
                  multisig: (data) => data.maybeWhen(
                    send: (data) => data.dest,
                    submit: (data) => data.dest,
                    orElse: () => null,
                  ),
                  orElse: () => null,
                ) ??
                data.recipient,
            orElse: () => null,
          );

          final recipient = dataRecipient ?? msgRecipient;

          final isOutgoing = recipient != null;

          final msgValue = (isOutgoing
                  ? e.transaction.outMessages.firstOrNull?.value
                  : e.transaction.inMessage.value) ??
              e.transaction.inMessage.value;

          final dataValue = e.data?.maybeWhen(
            dePoolOnRoundComplete: (data) => data.reward,
            walletInteraction: (data) => data.method.maybeWhen(
              multisig: (data) => data.maybeWhen(
                send: (data) => data.value,
                submit: (data) => data.value,
                orElse: () => null,
              ),
              orElse: () => null,
            ),
            orElse: () => null,
          );

          final value = dataValue ?? msgValue;

          final address = (isOutgoing ? recipient : sender) ?? tonWallet.address;

          final date = e.transaction.createdAt.toDateTime();

          final fees = e.transaction.totalFees;

          final hash = e.transaction.id.hash;

          final comment = e.data?.maybeWhen(
            comment: (data) => data,
            orElse: () => null,
          );

          final dePoolOnRoundCompleteNotification = e.data?.maybeWhen(
            dePoolOnRoundComplete: (data) => data,
            orElse: () => null,
          );

          final dePoolReceiveAnswerNotification = e.data?.maybeWhen(
            dePoolReceiveAnswer: (data) => data,
            orElse: () => null,
          );

          final tokenWalletDeployedNotification = e.data?.maybeWhen(
            tokenWalletDeployed: (data) => data,
            orElse: () => null,
          );

          final walletInteractionInfo = e.data?.maybeWhen(
            walletInteraction: (data) => data,
            orElse: () => null,
          );

          final transaction = TonWalletOrdinaryTransaction(
            lt: lt,
            prevTransactionLt: prevTransactionLt,
            isOutgoing: isOutgoing,
            value: value,
            address: address,
            date: date,
            fees: fees,
            hash: hash,
            comment: comment,
            dePoolOnRoundCompleteNotification: dePoolOnRoundCompleteNotification,
            dePoolReceiveAnswerNotification: dePoolReceiveAnswerNotification,
            tokenWalletDeployedNotification: tokenWalletDeployedNotification,
            walletInteractionInfo: walletInteractionInfo,
          );

          return transaction;
        },
      ).toList();

  List<TonWalletPendingTransaction> _mapPendingTransactions({
    required TonWallet tonWallet,
    required List<PendingTransactionWithAdditionalInfo> pendingTransactions,
  }) =>
      pendingTransactions.map(
        (e) {
          final expireAt = e.transaction.expireAt.toDateTime();

          final address = tonWallet.address;

          final date = e.createdAt.toDateTime();

          final transaction = TonWalletPendingTransaction(
            expireAt: expireAt,
            address: address,
            date: date,
          );

          return transaction;
        },
      ).toList();

  List<TonWalletExpiredTransaction> _mapExpiredTransactions({
    required TonWallet tonWallet,
    required List<PendingTransactionWithAdditionalInfo> expiredTransactions,
  }) =>
      expiredTransactions.map(
        (e) {
          final expireAt = e.transaction.expireAt.toDateTime();

          final address = e.transaction.src ?? tonWallet.address;

          final date = e.createdAt.toDateTime();

          final transaction = TonWalletExpiredTransaction(
            expireAt: expireAt,
            address: address,
            date: date,
          );

          return transaction;
        },
      ).toList();

  List<TonWalletMultisigOrdinaryTransaction> _mapMultisigOrdinaryTransactions({
    required TonWallet tonWallet,
    required List<TransactionWithData<TransactionAdditionalInfo?>> transactions,
    required List<MultisigPendingTransaction> multisigPendingTransactions,
  }) =>
      transactions
          .where(
        (e) => e.isOrdinaryTransaction(
          transactions: transactions,
          pendingTransactions: multisigPendingTransactions,
        ),
      )
          .map(
        (e) {
          final lt = e.transaction.id.lt;

          final prevTransactionLt = e.transaction.prevTransactionId?.lt;

          final multisigSubmitTransaction = e.multisigSubmitTransaction;

          final creator = multisigSubmitTransaction.custodian;

          final transactionId = multisigSubmitTransaction.transId;

          final confirmations = transactions
              .where((e) => e.isSubmitOrConfirmTransaction(transactionId))
              .map((e) => e.custodian)
              .toList();

          final msgSender = e.transaction.inMessage.src;

          final dataSender = e.data?.maybeWhen(
            walletInteraction: (data) => data.knownPayload?.maybeWhen(
              tokenSwapBack: (data) => data.callbackAddress,
              orElse: () => null,
            ),
            orElse: () => null,
          );

          final sender = dataSender ?? msgSender;

          final msgRecipient = e.transaction.outMessages.firstOrNull?.dst;

          final dataRecipient = e.data?.maybeWhen(
            walletInteraction: (data) =>
                data.knownPayload?.maybeWhen(
                  tokenOutgoingTransfer: (data) => data.to.data,
                  orElse: () => null,
                ) ??
                data.method.maybeWhen(
                  multisig: (data) => data.maybeWhen(
                    send: (data) => data.dest,
                    submit: (data) => data.dest,
                    orElse: () => null,
                  ),
                  orElse: () => null,
                ) ??
                data.recipient,
            orElse: () => null,
          );

          final recipient = dataRecipient ?? msgRecipient;

          final isOutgoing = recipient != null;

          final msgValue = (isOutgoing
                  ? e.transaction.outMessages.firstOrNull?.value
                  : e.transaction.inMessage.value) ??
              e.transaction.inMessage.value;

          final dataValue = e.data?.maybeWhen(
            dePoolOnRoundComplete: (data) => data.reward,
            walletInteraction: (data) => data.method.maybeWhen(
              multisig: (data) => data.maybeWhen(
                send: (data) => data.value,
                submit: (data) => data.value,
                orElse: () => null,
              ),
              orElse: () => null,
            ),
            orElse: () => null,
          );

          final value = dataValue ?? msgValue;

          final address = (isOutgoing ? recipient : sender) ?? tonWallet.address;

          final date = e.transaction.createdAt.toDateTime();

          final fees = e.transaction.totalFees;

          final hash = e.transaction.id.hash;

          final comment = e.data?.maybeWhen(
            comment: (data) => data,
            orElse: () => null,
          );

          final dePoolOnRoundCompleteNotification = e.data?.maybeWhen(
            dePoolOnRoundComplete: (data) => data,
            orElse: () => null,
          );

          final dePoolReceiveAnswerNotification = e.data?.maybeWhen(
            dePoolReceiveAnswer: (data) => data,
            orElse: () => null,
          );

          final tokenWalletDeployedNotification = e.data?.maybeWhen(
            tokenWalletDeployed: (data) => data,
            orElse: () => null,
          );

          final walletInteractionInfo = e.data?.maybeWhen(
            walletInteraction: (data) => data,
            orElse: () => null,
          );

          final transaction = TonWalletMultisigOrdinaryTransaction(
            lt: lt,
            prevTransactionLt: prevTransactionLt,
            creator: creator,
            confirmations: confirmations,
            custodians: tonWallet.custodians!,
            isOutgoing: isOutgoing,
            value: value,
            address: address,
            date: date,
            fees: fees,
            hash: hash,
            comment: comment,
            dePoolOnRoundCompleteNotification: dePoolOnRoundCompleteNotification,
            dePoolReceiveAnswerNotification: dePoolReceiveAnswerNotification,
            tokenWalletDeployedNotification: tokenWalletDeployedNotification,
            walletInteractionInfo: walletInteractionInfo,
          );

          return transaction;
        },
      ).toList();

  List<TonWalletMultisigPendingTransaction> _mapMultisigPendingTransactions({
    required TonWallet tonWallet,
    required List<TransactionWithData<TransactionAdditionalInfo?>> transactions,
    required List<MultisigPendingTransaction> multisigPendingTransactions,
  }) =>
      transactions.where((e) => e.isPendingTransaction(multisigPendingTransactions)).map(
        (e) {
          final lt = e.transaction.id.lt;

          final prevTransactionLt = e.transaction.prevTransactionId?.lt;

          final multisigPendingTransaction = multisigPendingTransactions
              .firstWhere((el) => el.id == e.multisigSubmitTransaction.transId);

          final creator = multisigPendingTransaction.creator;

          final msgSender = e.transaction.inMessage.src;

          final dataSender = e.data?.maybeWhen(
            walletInteraction: (data) => data.knownPayload?.maybeWhen(
              tokenSwapBack: (data) => data.callbackAddress,
              orElse: () => null,
            ),
            orElse: () => null,
          );

          final sender = dataSender ?? msgSender;

          final msgRecipient = e.transaction.outMessages.firstOrNull?.dst;

          final dataRecipient = e.data?.maybeWhen(
            walletInteraction: (data) =>
                data.knownPayload?.maybeWhen(
                  tokenOutgoingTransfer: (data) => data.to.data,
                  orElse: () => null,
                ) ??
                data.method.maybeWhen(
                  multisig: (data) => data.maybeWhen(
                    send: (data) => data.dest,
                    submit: (data) => data.dest,
                    orElse: () => null,
                  ),
                  orElse: () => null,
                ) ??
                data.recipient,
            orElse: () => null,
          );

          final recipient = dataRecipient ?? msgRecipient;

          final isOutgoing = recipient != null;

          final msgValue = (isOutgoing
                  ? e.transaction.outMessages.firstOrNull?.value
                  : e.transaction.inMessage.value) ??
              e.transaction.inMessage.value;

          final dataValue = e.data?.maybeWhen(
            dePoolOnRoundComplete: (data) => data.reward,
            walletInteraction: (data) => data.method.maybeWhen(
              multisig: (data) => data.maybeWhen(
                send: (data) => data.value,
                submit: (data) => data.value,
                orElse: () => null,
              ),
              orElse: () => null,
            ),
            orElse: () => null,
          );

          final value = dataValue ?? msgValue;

          final address = (isOutgoing ? recipient : sender) ?? tonWallet.address;

          final date = e.transaction.createdAt.toDateTime();

          final fees = e.transaction.totalFees;

          final hash = e.transaction.id.hash;

          final comment = e.data?.maybeWhen(
            comment: (data) => data,
            orElse: () => null,
          );

          final dePoolOnRoundCompleteNotification = e.data?.maybeWhen(
            dePoolOnRoundComplete: (data) => data,
            orElse: () => null,
          );

          final dePoolReceiveAnswerNotification = e.data?.maybeWhen(
            dePoolReceiveAnswer: (data) => data,
            orElse: () => null,
          );

          final tokenWalletDeployedNotification = e.data?.maybeWhen(
            tokenWalletDeployed: (data) => data,
            orElse: () => null,
          );

          final walletInteractionInfo = e.data?.maybeWhen(
            walletInteraction: (data) => data,
            orElse: () => null,
          );

          final signsReceived = multisigPendingTransaction.signsReceived;

          final signsRequired = multisigPendingTransaction.signsRequired;

          final confirmations = multisigPendingTransaction.confirmations;

          final transactionId = multisigPendingTransaction.id;

          final localCustodians = _keystore.entries
              .where((e) => tonWallet.custodians!.any((el) => el == e.publicKey))
              .toList();

          final initiatorKey =
              localCustodians.firstWhereOrNull((e) => e.publicKey == tonWallet.publicKey);

          final listOfKeys = [
            if (initiatorKey != null) initiatorKey,
            ...localCustodians.where((e) => e.publicKey != initiatorKey?.publicKey),
          ];

          final nonConfirmedLocalCustodians =
              listOfKeys.where((e) => confirmations.every((el) => el != e.publicKey));

          final publicKeys = nonConfirmedLocalCustodians.map((e) => e.publicKey).toList();

          final canConfirm = publicKeys.isNotEmpty;

          final timeForConfirmation = Duration(seconds: tonWallet.details.expirationTime);

          final expireAt = date.add(timeForConfirmation);

          final transaction = TonWalletMultisigPendingTransaction(
            lt: lt,
            prevTransactionLt: prevTransactionLt,
            creator: creator,
            confirmations: confirmations,
            custodians: tonWallet.custodians!,
            isOutgoing: isOutgoing,
            value: value,
            address: address,
            walletAddress: tonWallet.address,
            date: date,
            fees: fees,
            hash: hash,
            comment: comment,
            dePoolOnRoundCompleteNotification: dePoolOnRoundCompleteNotification,
            dePoolReceiveAnswerNotification: dePoolReceiveAnswerNotification,
            tokenWalletDeployedNotification: tokenWalletDeployedNotification,
            walletInteractionInfo: walletInteractionInfo,
            signsReceived: signsReceived,
            signsRequired: signsRequired,
            transactionId: transactionId,
            publicKeys: publicKeys,
            canConfirm: canConfirm,
            expireAt: expireAt,
          );

          return transaction;
        },
      ).toList();

  List<TonWalletMultisigExpiredTransaction> _mapMultisigExpiredTransactions({
    required TonWallet tonWallet,
    required List<TransactionWithData<TransactionAdditionalInfo?>> transactions,
    required List<MultisigPendingTransaction> multisigPendingTransactions,
  }) =>
      transactions
          .where(
        (e) => e.isExpiredTransaction(
          transactions: transactions,
          pendingTransactions: multisigPendingTransactions,
        ),
      )
          .map(
        (e) {
          final lt = e.transaction.id.lt;

          final prevTransactionLt = e.transaction.prevTransactionId?.lt;

          final multisigSubmitTransaction = e.multisigSubmitTransaction;

          final creator = multisigSubmitTransaction.custodian;

          final transactionId = multisigSubmitTransaction.transId;

          final confirmations = transactions
              .where((e) => e.isSubmitOrConfirmTransaction(transactionId))
              .map((e) => e.custodian)
              .toList();

          final msgSender = e.transaction.inMessage.src;

          final dataSender = e.data?.maybeWhen(
            walletInteraction: (data) => data.knownPayload?.maybeWhen(
              tokenSwapBack: (data) => data.callbackAddress,
              orElse: () => null,
            ),
            orElse: () => null,
          );

          final sender = dataSender ?? msgSender;

          final msgRecipient = e.transaction.outMessages.firstOrNull?.dst;

          final dataRecipient = e.data?.maybeWhen(
            walletInteraction: (data) =>
                data.knownPayload?.maybeWhen(
                  tokenOutgoingTransfer: (data) => data.to.data,
                  orElse: () => null,
                ) ??
                data.method.maybeWhen(
                  multisig: (data) => data.maybeWhen(
                    send: (data) => data.dest,
                    submit: (data) => data.dest,
                    orElse: () => null,
                  ),
                  orElse: () => null,
                ) ??
                data.recipient,
            orElse: () => null,
          );

          final recipient = dataRecipient ?? msgRecipient;

          final isOutgoing = recipient != null;

          final msgValue = (isOutgoing
                  ? e.transaction.outMessages.firstOrNull?.value
                  : e.transaction.inMessage.value) ??
              e.transaction.inMessage.value;

          final dataValue = e.data?.maybeWhen(
            dePoolOnRoundComplete: (data) => data.reward,
            walletInteraction: (data) => data.method.maybeWhen(
              multisig: (data) => data.maybeWhen(
                send: (data) => data.value,
                submit: (data) => data.value,
                orElse: () => null,
              ),
              orElse: () => null,
            ),
            orElse: () => null,
          );

          final value = dataValue ?? msgValue;

          final address = (isOutgoing ? recipient : sender) ?? tonWallet.address;

          final date = e.transaction.createdAt.toDateTime();

          final fees = e.transaction.totalFees;

          final hash = e.transaction.id.hash;

          final comment = e.data?.maybeWhen(
            comment: (data) => data,
            orElse: () => null,
          );

          final dePoolOnRoundCompleteNotification = e.data?.maybeWhen(
            dePoolOnRoundComplete: (data) => data,
            orElse: () => null,
          );

          final dePoolReceiveAnswerNotification = e.data?.maybeWhen(
            dePoolReceiveAnswer: (data) => data,
            orElse: () => null,
          );

          final tokenWalletDeployedNotification = e.data?.maybeWhen(
            tokenWalletDeployed: (data) => data,
            orElse: () => null,
          );

          final walletInteractionInfo = e.data?.maybeWhen(
            walletInteraction: (data) => data,
            orElse: () => null,
          );

          final transaction = TonWalletMultisigExpiredTransaction(
            lt: lt,
            prevTransactionLt: prevTransactionLt,
            creator: creator,
            confirmations: confirmations,
            custodians: tonWallet.custodians!,
            isOutgoing: isOutgoing,
            value: value,
            address: address,
            date: date,
            fees: fees,
            hash: hash,
            comment: comment,
            dePoolOnRoundCompleteNotification: dePoolOnRoundCompleteNotification,
            dePoolReceiveAnswerNotification: dePoolReceiveAnswerNotification,
            tokenWalletDeployedNotification: tokenWalletDeployedNotification,
            walletInteractionInfo: walletInteractionInfo,
          );

          return transaction;
        },
      ).toList();
}

extension on TransactionWithData<TransactionAdditionalInfo?> {
  bool get isMultisigTransaction =>
      data != null &&
      data!.maybeWhen(
        walletInteraction: (data) => data.method.maybeWhen(
          multisig: (data) => data.maybeWhen(
            submit: (data) => true,
            confirm: (data) => true,
            orElse: () => false,
          ),
          orElse: () => false,
        ),
        orElse: () => false,
      );

  bool isOrdinaryTransaction({
    required List<TransactionWithData<TransactionAdditionalInfo?>> transactions,
    required List<MultisigPendingTransaction> pendingTransactions,
  }) =>
      data != null &&
      data!.maybeWhen(
        walletInteraction: (data) => data.method.maybeWhen(
          multisig: (data) => data.maybeWhen(
            submit: (data) =>
                pendingTransactions.every((e) => e.id != data.transId) &&
                (transaction.outMessages.isNotEmpty ||
                    transactions
                        .where((e) => e.isConfirmTransaction(data.transId))
                        .any((e) => e.transaction.outMessages.isNotEmpty)),
            orElse: () => false,
          ),
          orElse: () => false,
        ),
        orElse: () => false,
      );

  bool isConfirmTransaction(String id) =>
      data != null &&
      data!.maybeWhen(
        walletInteraction: (data) => data.method.maybeWhen(
          multisig: (data) => data.maybeWhen(
            confirm: (data) => data.transactionId == id,
            orElse: () => false,
          ),
          orElse: () => false,
        ),
        orElse: () => false,
      );

  bool isSubmitOrConfirmTransaction(String id) =>
      data != null &&
      data!.maybeWhen(
        walletInteraction: (data) => data.method.maybeWhen(
          multisig: (data) => data.maybeWhen(
            submit: (data) => data.transId == id,
            confirm: (data) => data.transactionId == id,
            orElse: () => false,
          ),
          orElse: () => false,
        ),
        orElse: () => false,
      );

  bool isPendingTransaction(List<MultisigPendingTransaction> pendingTransactions) =>
      data != null &&
      data!.maybeWhen(
        walletInteraction: (data) => data.method.maybeWhen(
          multisig: (data) => data.maybeWhen(
            submit: (data) => pendingTransactions.any((e) => e.id == data.transId),
            orElse: () => false,
          ),
          orElse: () => false,
        ),
        orElse: () => false,
      );

  bool isExpiredTransaction({
    required List<TransactionWithData<TransactionAdditionalInfo?>> transactions,
    required List<MultisigPendingTransaction> pendingTransactions,
  }) =>
      data != null &&
      data!.maybeWhen(
        walletInteraction: (data) => data.method.maybeWhen(
          multisig: (data) => data.maybeWhen(
            submit: (data) =>
                pendingTransactions.every((e) => e.id != data.transId) &&
                (transaction.outMessages.isEmpty ||
                    transactions
                        .where((e) => e.isConfirmTransaction(data.transId))
                        .any((e) => e.transaction.outMessages.isEmpty)),
            orElse: () => false,
          ),
          orElse: () => false,
        ),
        orElse: () => false,
      );

  MultisigSubmitTransaction get multisigSubmitTransaction => data!.maybeWhen(
        walletInteraction: (data) => data.method.maybeWhen(
          multisig: (data) => data.maybeWhen(
            submit: (data) => data,
            orElse: () => null,
          ),
          orElse: () => null,
        ),
        orElse: () => null,
      )!;

  String get custodian => data!.maybeWhen(
        walletInteraction: (data) => data.method.maybeWhen(
          multisig: (data) => data.maybeWhen(
            submit: (data) => data.custodian,
            confirm: (data) => data.custodian,
            orElse: () => null,
          ),
          orElse: () => null,
        ),
        orElse: () => null,
      )!;
}

extension on TonWallet {
  Stream<List<MultisigPendingTransaction>> get unconfirmedTransactionsStream =>
      onStateChangedStream.map((_) => unconfirmedTransactions);
}
