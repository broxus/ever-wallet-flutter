import 'dart:async';

import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tuple/tuple.dart';

import '../../logger.dart';
import 'current_accounts_repository.dart';
import 'transport_repository.dart';

@lazySingleton
class TokenWalletsSubscriptionsRepository {
  final TransportRepository _transportRepository;
  final CurrentAccountsRepository _currentAccountsRepository;
  final _tokenWalletsSubject = BehaviorSubject<List<TokenWallet>>.seeded([]);

  TokenWalletsSubscriptionsRepository(
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

  Stream<List<TokenWallet>> get tokenWalletsStream => _tokenWalletsSubject.stream;

  List<TokenWallet> get tokenWallets => _tokenWalletsSubject.value;

  Future<TokenWallet> subscribeToTokenWallet({
    required String owner,
    required String rootTokenContract,
  }) async {
    final existingTokenWallet = _tokenWalletsSubject.value.firstWhereOrNull(
      (e) => e.owner == owner && e.symbol.rootTokenContract == rootTokenContract,
    );

    if (existingTokenWallet != null) {
      return existingTokenWallet;
    }

    final transport = _transportRepository.transport;

    final tokenWallet = await TokenWallet.subscribe(
      transport: transport,
      owner: owner,
      rootTokenContract: rootTokenContract,
    );

    final tokenWallets = [..._tokenWalletsSubject.value];

    tokenWallets.add(tokenWallet);

    _tokenWalletsSubject.add(tokenWallets);

    return tokenWallet;
  }

  Future<void> removeTokenWalletSubscription({
    required String owner,
    required String rootTokenContract,
  }) async {
    final tokenWallet = _tokenWalletsSubject.value.firstWhereOrNull(
      (e) => e.owner == owner && e.symbol.rootTokenContract == rootTokenContract,
    );

    if (tokenWallet == null) {
      return;
    }

    final subscriptions = [..._tokenWalletsSubject.value];

    subscriptions.remove(tokenWallet);

    _tokenWalletsSubject.add(subscriptions);

    await tokenWallet.freePtr();
  }

  Future<void> clearTokenWalletsSubscriptions() async {
    final subscriptions = [..._tokenWalletsSubject.value];

    _tokenWalletsSubject.add([]);

    for (final subscription in subscriptions) {
      await subscription.freePtr();
    }
  }

  Future<void> _transportStreamListener() async {
    try {
      final oldTokenWallets = tokenWallets.map(
        (e) => Tuple2(
          e.owner,
          e.symbol.rootTokenContract,
        ),
      );

      await clearTokenWalletsSubscriptions();

      for (final oldTokenWallet in oldTokenWallets) {
        await subscribeToTokenWallet(
          owner: oldTokenWallet.item1,
          rootTokenContract: oldTokenWallet.item2,
        );
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<void> _currentAccountsStreamListener(Iterable<List<AssetsList>> event) async {
    try {
      final prev = event.first;
      final next = event.last;

      final networkGroup = _transportRepository.transport.connectionData.group;

      final currentTokenWallets = next
          .map(
            (e) =>
                e.additionalAssets[networkGroup]?.tokenWallets.map(
                  (el) => Tuple2(
                    e.tonWallet.address,
                    el.rootTokenContract,
                  ),
                ) ??
                [],
          )
          .expand((e) => e);
      final previousTokenWallets = prev
          .map(
            (e) =>
                e.additionalAssets[networkGroup]?.tokenWallets.map(
                  (el) => Tuple2(
                    e.tonWallet.address,
                    el.rootTokenContract,
                  ),
                ) ??
                [],
          )
          .expand((e) => e);

      final addedTokenWallets = [...currentTokenWallets]
        ..removeWhere((e) => previousTokenWallets.any((el) => el.item1 == e.item1 && el.item2 == e.item2));
      final removedTokenWallets = [...previousTokenWallets]
        ..removeWhere((e) => currentTokenWallets.any((el) => el.item1 == e.item1 && el.item2 == e.item2));

      for (final addedTokenWallet in addedTokenWallets) {
        await subscribeToTokenWallet(
          owner: addedTokenWallet.item1,
          rootTokenContract: addedTokenWallet.item2,
        );
      }

      for (final removedTokenWallet in removedTokenWallets) {
        await removeTokenWalletSubscription(
          owner: removedTokenWallet.item1,
          rootTokenContract: removedTokenWallet.item2,
        );
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
