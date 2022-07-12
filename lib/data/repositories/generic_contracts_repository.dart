import 'dart:async';

import 'package:collection/collection.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/models/contract_updates_subscription.dart';
import 'package:ever_wallet/data/sources/remote/transport_source.dart';
import 'package:ever_wallet/logger.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tuple/tuple.dart';

class GenericContractsRepository {
  final _lock = Lock();
  final TransportSource _transportSource;
  final _currentContractSubscriptionsSubject = BehaviorSubject<List<String>>.seeded([]);
  final _genericContractsSubject = BehaviorSubject<List<GenericContract>>.seeded([]);
  late final StreamSubscription _currentContractSubscriptionsStreamSubscription;

  GenericContractsRepository(this._transportSource) {
    _currentContractSubscriptionsStreamSubscription =
        Rx.combineLatest3<List<String>, Transport, void, Tuple2<List<String>, Transport>>(
      _currentContractSubscriptionsSubject,
      _transportSource.transportStream,
      Stream<void>.periodic(kSubscriptionRefreshTimeout).startWith(null),
      (a, b, c) => Tuple2(a, b),
    ).listen(
      (event) => _lock.synchronized(() => _currentContractSubscriptionsStreamListener(event)),
    );
  }

  Map<String, ContractUpdatesSubscription> get subscriptions => {
        for (final e in _currentContractSubscriptionsSubject.value)
          e: const ContractUpdatesSubscription(state: true, transactions: true)
      };

  Stream<Tuple3<String, List<Transaction>, TransactionsBatchInfo>> get transactionsStream =>
      _genericContractsSubject.expand((e) => e).flatMap(
            (v) => v.onTransactionsFoundStream.asyncMap(
              (e) async => Tuple3(
                v.address,
                e.transactions,
                e.batchInfo,
              ),
            ),
          );

  Stream<Tuple2<String, ContractState>> get stateChangesStream =>
      _genericContractsSubject.expand((e) => e).flatMap(
            (v) => v.onStateChangedStream.asyncMap(
              (e) async => Tuple2(
                v.address,
                e.newState,
              ),
            ),
          );

  Future<Transaction> executeTransactionLocally({
    required String address,
    required SignedMessage signedMessage,
    required TransactionExecutionOptions options,
  }) async {
    final genericContract = await _getGenericContract(address);

    final transaction = await genericContract.executeTransactionLocally(
      signedMessage: signedMessage,
      options: options,
    );

    return transaction;
  }

  Future<Transaction?> send({
    required String address,
    required SignedMessage signedMessage,
  }) async {
    final genericContract = await _getGenericContract(address);

    final transaction = await genericContract.send(signedMessage);

    return transaction;
  }

  void subscribe(String address) => _currentContractSubscriptionsSubject.add([
        ...{
          ..._currentContractSubscriptionsSubject.value.where((e) => e != address).toList(),
          address,
        }
      ]);

  void unsubscribe(String address) => _currentContractSubscriptionsSubject
      .add(_currentContractSubscriptionsSubject.value.where((e) => e != address).toList());

  void clear() => _currentContractSubscriptionsSubject.add([]);

  Future<void> dispose() async {
    await _currentContractSubscriptionsStreamSubscription.cancel();

    await _currentContractSubscriptionsSubject.close();
    await _genericContractsSubject.close();
  }

  Future<GenericContract> _getGenericContract(String address) => _genericContractsSubject
      .map((e) => e.firstWhereOrNull((e) => e.address == address))
      .whereType<GenericContract>()
      .first
      .timeout(
        kSubscriptionRefreshTimeout * 2,
        onTimeout: () => throw Exception('Generic contract not found'),
      );

  Future<void> _currentContractSubscriptionsStreamListener(
    Tuple2<List<String>, Transport> event,
  ) async {
    try {
      final contractSubscriptions = event.item1;
      final transport = event.item2;

      final genericContractsForUnsubscription = _genericContractsSubject.value.where(
        (e) => e.transport != transport || !contractSubscriptions.any((el) => el == e.address),
      );

      for (final genericContractForUnsubscription in genericContractsForUnsubscription) {
        _genericContractsSubject.add(
          _genericContractsSubject.value
              .where((e) => e != genericContractForUnsubscription)
              .toList(),
        );

        genericContractForUnsubscription.dispose();
      }

      final contractSubscriptionsForSubscription = contractSubscriptions.where(
        (e) => !_genericContractsSubject.value.any((el) => el.address == e),
      );

      for (final contractSubscriptionForSubscription in contractSubscriptionsForSubscription) {
        try {
          final genericContract = await GenericContract.subscribe(
            transport: transport,
            address: contractSubscriptionForSubscription,
            preloadTransactions: false,
          );

          _genericContractsSubject.add([..._genericContractsSubject.value, genericContract]);
        } catch (err, st) {
          logger.e(err, err, st);
        }
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
