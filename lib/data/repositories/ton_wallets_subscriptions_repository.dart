import 'dart:async';

import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

import '../../logger.dart';
import 'current_accounts_repository.dart';
import 'transport_repository.dart';

@lazySingleton
class TonWalletsSubscriptionsRepository {
  final TransportRepository _transportRepository;
  final CurrentAccountsRepository _currentAccountsRepository;
  final _tonWalletsSubject = BehaviorSubject<List<TonWallet>>.seeded([]);

  TonWalletsSubscriptionsRepository(
    this._transportRepository,
    this._currentAccountsRepository,
  ) {
    final lock = Lock();
    _transportRepository.transportStream.skip(1).listen((e) => lock.synchronized(() => _transportStreamListener()));
    _currentAccountsRepository.currentAccountsStream
        .startWith(const [])
        .pairwise()
        .listen((e) => lock.synchronized(() => _currentAccountsStreamListener(e)));
  }

  Stream<List<TonWallet>> get tonWalletsStream => _tonWalletsSubject.stream;

  List<TonWallet> get tonWallets => _tonWalletsSubject.value;

  Future<TonWallet> subscribeToTonWallet({
    required String address,
    required int workchain,
    required String publicKey,
    required WalletType walletType,
  }) async {
    final existingTonWallet = _tonWalletsSubject.value.firstWhereOrNull((e) => e.address == address);

    if (existingTonWallet != null) {
      return existingTonWallet;
    }

    final transport = _transportRepository.transport;

    final tonWallet = await TonWallet.subscribe(
      transport: transport,
      workchain: workchain,
      publicKey: publicKey,
      walletType: walletType,
    );

    final tonWallets = [..._tonWalletsSubject.value];

    tonWallets.add(tonWallet);

    _tonWalletsSubject.add(tonWallets);

    return tonWallet;
  }

  Future<TonWallet> subscribeByAddressToTonWallet(String address) async {
    final existingTonWallet = _tonWalletsSubject.value.firstWhereOrNull((e) => e.address == address);

    if (existingTonWallet != null) {
      return existingTonWallet;
    }

    final transport = _transportRepository.transport;

    final tonWallet = await TonWallet.subscribeByAddress(
      transport: transport,
      address: address,
    );

    final tonWallets = [..._tonWalletsSubject.value];

    tonWallets.add(tonWallet);

    _tonWalletsSubject.add(tonWallets);

    return tonWallet;
  }

  Future<void> removeTonWalletSubscription(String address) async {
    final tonWallet = _tonWalletsSubject.value.firstWhereOrNull((e) => e.address == address);

    if (tonWallet == null) {
      return;
    }

    final subscriptions = [..._tonWalletsSubject.value];

    subscriptions.removeWhere((e) => e.address == tonWallet.address);

    _tonWalletsSubject.add(subscriptions);

    await tonWallet.freePtr();
  }

  Future<void> clearTonWalletsSubscriptions() async {
    final subscriptions = [..._tonWalletsSubject.value];

    _tonWalletsSubject.add([]);

    for (final subscription in subscriptions) {
      await subscription.freePtr();
    }
  }

  Future<void> _transportStreamListener() async {
    try {
      final oldTonWallets = tonWallets.map((e) => e.address);

      await clearTonWalletsSubscriptions();

      for (final oldTonWallet in oldTonWallets) {
        await subscribeByAddressToTonWallet(oldTonWallet);
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
        await subscribeToTonWallet(
          address: addedTonWallet.address,
          workchain: addedTonWallet.workchain,
          publicKey: addedTonWallet.publicKey,
          walletType: addedTonWallet.contract,
        );
      }

      for (final removedTonWallet in removedTonWallets) {
        await removeTonWalletSubscription(removedTonWallet.address);
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
