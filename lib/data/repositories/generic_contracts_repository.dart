import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tuple/tuple.dart';

import '../../logger.dart';
import '../constants.dart';
import '../extensions.dart';
import '../models/contract_updates_subscription.dart';
import '../sources/remote/transport_source.dart';

@lazySingleton
class GenericContractsRepository {
  final TransportSource _transportSource;
  final _currentContractSubscriptionsSubject = BehaviorSubject<List<String>>.seeded([]);
  final _genericContractsSubject = BehaviorSubject<List<GenericContract>>.seeded([]);
  final _lock = Lock();

  GenericContractsRepository(this._transportSource) {
    Rx.combineLatest3<List<String>, Transport, void, Tuple2<List<String>, Transport>>(
      _currentContractSubscriptionsSubject,
      _transportSource.transportStream,
      Stream<void>.periodic(kSubscriptionRefreshTimeout).startWith(null),
      (a, b, c) => Tuple2(a, b),
    ).listen((event) => _lock.synchronized(() => _currentContractSubscriptionsStreamListener(event)));
  }

  Map<String, ContractUpdatesSubscription> get subscriptions => {
        for (final e in _currentContractSubscriptionsSubject.value)
          e: const ContractUpdatesSubscription(state: true, transactions: true)
      };

  Stream<Tuple3<String, List<Transaction>, TransactionsBatchInfo>> get transactionsStream =>
      _genericContractsSubject.expand((e) => e).flatMap(
            (v) => v.onTransactionsFoundStream.asyncMap(
              (e) async => Tuple3(
                await v.address,
                e.transactions,
                e.batchInfo,
              ),
            ),
          );

  Stream<Tuple2<String, ContractState>> get stateChangesStream => _genericContractsSubject.expand((e) => e).flatMap(
        (v) => v.onStateChangedStream.asyncMap(
          (e) async => Tuple2(
            await v.address,
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

  Future<PendingTransaction> send({
    required String address,
    required SignedMessage signedMessage,
  }) async {
    final genericContract = await _getGenericContract(address);

    final pendingTransaction = await genericContract.send(signedMessage);

    return pendingTransaction;
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

  Future<GenericContract> _getGenericContract(String address) => _genericContractsSubject
      .asyncMap((e) async => e.asyncFirstWhereOrNull((e) async => await e.address == address))
      .whereType<GenericContract>()
      .first
      .timeout(
        kSubscriptionRefreshTimeout * 2,
        onTimeout: () => throw Exception('Generic contract not found'),
      );

  Future<void> _currentContractSubscriptionsStreamListener(Tuple2<List<String>, Transport> event) async {
    try {
      final contractSubscriptions = event.item1;
      final transport = event.item2;

      final genericContractsForUnsubscription = await _genericContractsSubject.value.asyncWhere(
        (e) async =>
            e.transport != transport || !await contractSubscriptions.asyncAny((el) async => el == await e.address),
      );

      for (final genericContractForUnsubscription in genericContractsForUnsubscription) {
        _genericContractsSubject
            .add(_genericContractsSubject.value.where((e) => e != genericContractForUnsubscription).toList());

        genericContractForUnsubscription.freePtr();
      }

      final contractSubscriptionsForSubscription = await contractSubscriptions.asyncWhere(
        (e) async => !await _genericContractsSubject.value.asyncAny((el) async => await el.address == e),
      );

      for (final contractSubscriptionForSubscription in contractSubscriptionsForSubscription) {
        try {
          final genericContract = await GenericContract.subscribe(
            transport: transport,
            address: contractSubscriptionForSubscription,
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
