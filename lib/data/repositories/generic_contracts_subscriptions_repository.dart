import 'dart:async';

import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import 'transport_repository.dart';

@lazySingleton
class GenericContractsSubscriptionsRepository {
  final TransportRepository _transportRepository;
  final _genericContractsSubject = BehaviorSubject<Map<String, List<GenericContract>>>.seeded({});

  GenericContractsSubscriptionsRepository(
    this._transportRepository,
  );

  Stream<Map<String, List<GenericContract>>> get genericContractsStream => _genericContractsSubject.stream;

  Map<String, List<GenericContract>> get genericContracts => _genericContractsSubject.value;

  Future<GenericContract> subscribeToGenericContract({
    required String origin,
    required String address,
  }) async {
    final transport = _transportRepository.transport;

    final genericContract = await GenericContract.subscribe(
      transport: transport,
      address: address,
    );

    final subscriptions = {..._genericContractsSubject.value};
    subscriptions[origin] = [...subscriptions[origin] ?? [], genericContract];

    _genericContractsSubject.add(subscriptions);

    return genericContract;
  }

  Future<void> removeGenericContractSubscription({
    required String origin,
    required String address,
  }) async {
    final subscriptions = {..._genericContractsSubject.value};

    final genericContract = subscriptions[origin]?.firstWhereOrNull((e) => e.address == address);

    if (genericContract == null) {
      return;
    }

    subscriptions[origin] = [...subscriptions[origin]?.where((e) => e != genericContract) ?? []];

    _genericContractsSubject.add(subscriptions);

    await genericContract.freePtr();
  }

  Future<void> removeOriginGenericContractSubscriptions(String origin) async {
    final subscriptions = {..._genericContractsSubject.value};

    final genericContracts = subscriptions[origin];

    if (genericContracts == null) {
      return;
    }

    subscriptions[origin] = [];

    _genericContractsSubject.add(subscriptions);

    for (final genericContract in genericContracts) {
      await genericContract.freePtr();
    }
  }

  Future<void> clearGenericContractsSubscriptions() async {
    final subscriptions = {..._genericContractsSubject.value};

    _genericContractsSubject.add({});

    for (final subscription in subscriptions.values.expand((e) => e)) {
      await subscription.freePtr();
    }
  }

  Map<String, ContractUpdatesSubscription> getOriginSubscriptions(String origin) {
    final originSubscriptions = [..._genericContractsSubject.value[origin] ?? []];

    final map = <String, ContractUpdatesSubscription>{};

    for (final subscription in originSubscriptions) {
      map[subscription.address] = const ContractUpdatesSubscription(state: true, transactions: true);
    }

    return map;
  }
}
