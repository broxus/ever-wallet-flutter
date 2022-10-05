import 'dart:async';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:ever_wallet/application/main/browser/events/models/contract_state_changed_event.dart';
import 'package:ever_wallet/application/main/browser/events/models/transactions_found_event.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/models/contract_updates_subscription.dart';
import 'package:ever_wallet/data/sources/local/app_lifecycle_state_source.dart';
import 'package:ever_wallet/data/sources/remote/transport_source.dart';
import 'package:ever_wallet/logger.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tuple/tuple.dart';

class GenericContractsRepository {
  final _lock = Lock();
  final TransportSource _transportSource;
  final AppLifecycleStateSource _appLifecycleStateSource;
  final _genericContractsSubject = BehaviorSubject<List<GenericContract>>.seeded([]);
  final _contractUpdatesSubscriptionsSubject =
      BehaviorSubject<List<Tuple4<int, String, String, ContractUpdatesSubscription>>>.seeded([]);
  late final Timer _pollingTimer;
  late final StreamSubscription _transportStreamSubscription;

  GenericContractsRepository({
    required TransportSource transportSource,
    required AppLifecycleStateSource appLifecycleStateSource,
  })  : _transportSource = transportSource,
        _appLifecycleStateSource = appLifecycleStateSource {
    _pollingTimer = Timer.periodic(kSubscriptionRefreshTimeout, _pollingTimerCallback);

    _transportStreamSubscription = _transportSource.transportStream
        .listen((e) => _lock.synchronized(() => _transportStreamListener(e)));
  }

  Map<String, ContractUpdatesSubscription>? tabSubscriptions(int tabId) => {
        for (final v in _contractUpdatesSubscriptionsSubject.value.where((e) => e.item1 == tabId))
          v.item3: v.item4,
      };

  Stream<TransactionsFoundEvent> tabTransactionsStream(int tabId) =>
      _contractUpdatesSubscriptionsSubject
          .map(
            (e) => _contractUpdatesSubscriptionsSubject.value
                .where((e) => e.item1 == tabId && e.item4.transactions == true)
                .map((e) => e.item3),
          )
          .flatMap(
            (v) => _genericContractsSubject
                .map((e) => e.where((e) => v.contains(e.address)))
                .expand((e) => e)
                .flatMap(
                  (v) => v.onTransactionsFoundStream.map(
                    (e) => TransactionsFoundEvent(
                      address: v.address,
                      transactions: e.item1,
                      info: e.item2,
                    ),
                  ),
                ),
          );

  Stream<ContractStateChangedEvent> tabStateChangesStream(int tabId) =>
      _contractUpdatesSubscriptionsSubject
          .map(
            (e) => _contractUpdatesSubscriptionsSubject.value
                .where((e) => e.item1 == tabId && e.item4.state == true)
                .map((e) => e.item3),
          )
          .flatMap(
            (v) => _genericContractsSubject
                .map((e) => e.where((e) => v.contains(e.address)))
                .expand((e) => e)
                .flatMap(
                  (v) => v.onStateChangedStream.map(
                    (e) => ContractStateChangedEvent(
                      address: v.address,
                      state: e,
                    ),
                  ),
                ),
          );

  Future<Transaction> executeTransactionLocally({
    required String address,
    required SignedMessage signedMessage,
    required TransactionExecutionOptions options,
  }) async {
    final genericContract = _genericContract(address);

    final transaction = await genericContract.executeTransactionLocally(
      signedMessage: signedMessage,
      options: options,
    );

    return transaction;
  }

  Future<Transaction> send({
    required String address,
    required SignedMessage signedMessage,
  }) async {
    final genericContract = _genericContract(address);

    final transport = genericContract.transport;

    if (transport is GqlTransport) {
      var currentBlockId = await transport.getLatestBlockId(address);

      final pendingTransaction = await genericContract.send(signedMessage);

      final completer = Completer<Transaction>();

      genericContract.onMessageSentStream
          .firstWhere((e) => e.item1 == pendingTransaction)
          .timeout(pendingTransaction.expireAt.toTimeout())
          .then((v) => completer.complete(v.item2))
          .onError((err, st) => completer.completeError(err!));

      () async {
        while (genericContract.pollingMethod == PollingMethod.reliable) {
          try {
            final nextBlockId = await transport.waitForNextBlockId(
              currentBlockId: currentBlockId,
              address: address,
              timeout: kNextBlockTimeout.inSeconds,
            );

            final block = await transport.getBlock(nextBlockId);

            await genericContract.handleBlock(block);

            currentBlockId = nextBlockId;
          } catch (err, st) {
            logger.e('Reliable polling error', err, st);
            break;
          }
        }
      }();

      return completer.future;
    } else if (transport is JrpcTransport) {
      final pendingTransaction = await genericContract.send(signedMessage);

      final completer = Completer<Transaction>();

      genericContract.onMessageSentStream
          .firstWhere((e) => e.item1 == pendingTransaction)
          .timeout(pendingTransaction.expireAt.toTimeout())
          .then((v) => completer.complete(v.item2))
          .onError((err, st) => completer.completeError(err!));

      () async {
        while (genericContract.pollingMethod == PollingMethod.reliable) {
          try {
            await genericContract.refresh();
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

  Future<void> subscribe({
    required int tabId,
    required String origin,
    required String address,
    required ContractUpdatesSubscription contractUpdatesSubscription,
  }) async {
    final transport = _transportSource.transport;

    var genericContract =
        _genericContractsSubject.value.firstWhereOrNull((e) => e.address == address);

    if (genericContract == null) {
      genericContract = await GenericContract.subscribe(
        transport: transport,
        address: address,
        preloadTransactions: false,
      );

      final genericContracts = [
        ..._genericContractsSubject.value,
        genericContract,
      ];

      _genericContractsSubject.add(genericContracts);
    }

    final contractUpdatesSubscriptions = [
      ..._contractUpdatesSubscriptionsSubject.value
          .where((e) => e.item1 != tabId && e.item2 != origin && e.item3 != address),
      Tuple4(tabId, origin, address, contractUpdatesSubscription),
    ];

    _contractUpdatesSubscriptionsSubject.add(contractUpdatesSubscriptions);
  }

  Future<void> unsubscribe({
    required int tabId,
    required String origin,
    required String address,
  }) async {
    final contractUpdatesSubscriptions = [
      ..._contractUpdatesSubscriptionsSubject.value
          .where((e) => e.item1 != tabId && e.item2 != origin && e.item3 != address),
    ];

    if (!contractUpdatesSubscriptions.any((e) => e.item3 == address)) {
      final genericContract =
          _genericContractsSubject.value.firstWhere((e) => e.address == address);

      final genericContracts = [
        ..._genericContractsSubject.value.where((e) => e != genericContract),
      ];

      _genericContractsSubject.add(genericContracts);

      genericContract.dispose();
    }

    _contractUpdatesSubscriptionsSubject.add(contractUpdatesSubscriptions);
  }

  Future<void> unsubscribeTab(int tabId) async {
    final contractUpdatesSubscriptions = [
      ..._contractUpdatesSubscriptionsSubject.value.where((e) => e.item1 != tabId),
    ];

    _contractUpdatesSubscriptionsSubject.add(contractUpdatesSubscriptions);

    await _unsubscribeUnused();
  }

  Future<void> unsubscribeOrigin(String origin) async {
    final contractUpdatesSubscriptions = [
      ..._contractUpdatesSubscriptionsSubject.value.where((e) => e.item2 != origin),
    ];

    _contractUpdatesSubscriptionsSubject.add(contractUpdatesSubscriptions);

    await _unsubscribeUnused();
  }

  Future<void> dispose() async {
    _pollingTimer.cancel();

    await _transportStreamSubscription.cancel();

    await _genericContractsSubject.close();
    await _contractUpdatesSubscriptionsSubject.close();

    for (final genericContract in _genericContractsSubject.value) {
      genericContract.dispose();
    }
  }

  void _pollingTimerCallback(Timer timer) {
    final appLifecycleState = _appLifecycleStateSource.appLifecycleState;
    final appIsActive = appLifecycleState == AppLifecycleState.resumed ||
        appLifecycleState == AppLifecycleState.inactive;

    if (appIsActive) {
      for (final genericContract in _genericContractsSubject.value) {
        if (genericContract.pollingMethod == PollingMethod.manual) {
          genericContract.refresh();
        }
      }
    }
  }

  Future<void> _unsubscribeUnused() async {
    final contractUpdatesSubscriptions = [..._contractUpdatesSubscriptionsSubject.value];

    final genericContracts = [..._genericContractsSubject.value];

    final genericContractsForUnsubscription = genericContracts
        .where((e) => !contractUpdatesSubscriptions.any((el) => el.item3 == e.address))
        .toList();

    genericContracts.removeWhere((e) => genericContractsForUnsubscription.contains(e));

    _genericContractsSubject.add(genericContracts);

    for (final genericContract in genericContractsForUnsubscription) {
      genericContract.dispose();
    }
  }

  void _transportStreamListener(Transport event) {
    try {
      _contractUpdatesSubscriptionsSubject.add([]);

      final genericContracts = [..._genericContractsSubject.value];

      for (final genericContractForUnsubscription in genericContracts) {
        genericContractForUnsubscription.dispose();
      }

      _genericContractsSubject.add([]);
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  GenericContract _genericContract(String address) =>
      _genericContractsSubject.value.firstWhere((e) => e.address == address);
}
