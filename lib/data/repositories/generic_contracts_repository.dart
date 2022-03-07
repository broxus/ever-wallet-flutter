import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tuple/tuple.dart';

import '../../logger.dart';
import '../extensions.dart';
import '../sources/local/keystore_source.dart';
import '../sources/remote/transport_source.dart';

@lazySingleton
class GenericContractsRepository {
  final TransportSource _transportSource;
  final KeystoreSource _keystoreSource;
  final _genericContractsSubject = BehaviorSubject<List<GenericContract>>.seeded([]);
  final _lock = Lock();

  GenericContractsRepository(
    this._transportSource,
    this._keystoreSource,
  ) {
    _transportSource.transportStream
        .skip(1)
        .whereType<Transport>()
        .listen((event) => _lock.synchronized(() => _transportStreamListener()));
  }

  Future<Map<String, ContractUpdatesSubscription>> get subscriptions => _genericContractsSubject.value
      .asyncMap(
        (e) async => MapEntry(
          await e.address,
          const ContractUpdatesSubscription(
            state: true,
            transactions: true,
          ),
        ),
      )
      .then((v) => Map.fromEntries(v));

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
    required String publicKey,
    required String password,
    required UnsignedMessage message,
    required TransactionExecutionOptions options,
  }) async {
    final genericContract =
        await _genericContractsSubject.value.asyncFirstWhereOrNull((e) async => await e.address == address);

    if (genericContract == null) throw Exception('Generic contract not found');

    final signInput = _keystoreSource.keys.firstWhere((e) => e.publicKey == publicKey).signInput(password);

    final transaction = await genericContract.executeTransactionLocally(
      keystore: _keystoreSource.keystore,
      message: message,
      signInput: signInput,
      options: options,
    );

    return transaction;
  }

  Future<PendingTransaction> send({
    required String address,
    required String publicKey,
    required String password,
    required UnsignedMessage message,
  }) async {
    final genericContract =
        await _genericContractsSubject.value.asyncFirstWhereOrNull((e) async => await e.address == address);

    if (genericContract == null) throw Exception('Generic contract not found');

    final signInput = _keystoreSource.keys.firstWhere((e) => e.publicKey == publicKey).signInput(password);

    final pendingTransaction = await genericContract.send(
      keystore: _keystoreSource.keystore,
      message: message,
      signInput: signInput,
    );

    return pendingTransaction;
  }

  Future<void> subscribe(String address) => _subscribe(address);

  Future<void> unsubscribe(String address) => _unsubscribe(address);

  void clear() => _clear();

  Future<GenericContract> _subscribe(String address) async {
    var genericContract =
        await _genericContractsSubject.value.asyncFirstWhereOrNull((e) async => await e.address == address);

    if (genericContract != null) return genericContract;

    final transport = _transportSource.transport;

    if (transport == null) throw Exception('Transport unavailable');

    genericContract = await GenericContract.subscribe(
      transport: transport,
      address: address,
    );

    _genericContractsSubject.add([..._genericContractsSubject.value, genericContract]);

    return genericContract;
  }

  Future<void> _unsubscribe(String address) async {
    final genericContract =
        await _genericContractsSubject.value.asyncFirstWhereOrNull((e) async => await e.address == address);

    if (genericContract == null) return;

    final genericContracts = _genericContractsSubject.value.where((e) => e != genericContract).toList();

    _genericContractsSubject.add(genericContracts);

    genericContract.freePtr();
  }

  void _clear() {
    final genericContracts = [..._genericContractsSubject.value];

    _genericContractsSubject.add([]);

    for (final genericContract in genericContracts) {
      genericContract.freePtr();
    }
  }

  Future<void> _transportStreamListener() async {
    try {
      final genericContracts = await Future.wait(_genericContractsSubject.value.map((e) => e.address));

      _clear();

      for (final genericContract in genericContracts) {
        await _subscribe(genericContract);
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
