import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tuple/tuple.dart';

import '../../logger.dart';
import '../constants.dart';
import '../extensions.dart';
import '../models/token_wallet_info.dart';
import '../sources/local/accounts_storage_source.dart';
import '../sources/local/hive_source.dart';
import '../sources/remote/transport_source.dart';

@lazySingleton
class TokenWalletsRepository {
  final AccountsStorageSource _accountsStorageSource;
  final TransportSource _transportSource;
  final HiveSource _hiveSource;
  final _tokenWalletsSubject = BehaviorSubject<List<TokenWallet>>.seeded([]);
  final _lock = Lock();

  TokenWalletsRepository(
    this._accountsStorageSource,
    this._transportSource,
    this._hiveSource,
  ) {
    Rx.combineLatest3<List<AssetsList>, Transport, void, Tuple2<List<AssetsList>, Transport>>(
      _accountsStorageSource.currentAccountsStream,
      _transportSource.transportStream,
      Stream<void>.periodic(kSubscriptionRefreshTimeout).startWith(null),
      (a, b, c) => Tuple2(a, b),
    ).listen((event) => _lock.synchronized(() => _currentAccountsStreamListener(event)));

    _accountsStorageSource.accountsStream
        .skip(1)
        .startWith(const [])
        .pairwise()
        .listen((event) => _lock.synchronized(() => _accountsStreamListener(event)));
  }

  Future<TokenWalletInfo> getInfo({
    required String owner,
    required String rootTokenContract,
  }) async {
    final tokenWallet = await _getTokenWallet(
      owner: owner,
      rootTokenContract: rootTokenContract,
    );

    final tokenWalletInfo = TokenWalletInfo(
      owner: await tokenWallet.owner,
      address: await tokenWallet.address,
      symbol: await tokenWallet.symbol,
      version: await tokenWallet.version,
      balance: await tokenWallet.balance,
      contractState: await tokenWallet.contractState,
    );

    await _hiveSource.saveTokenWalletInfo(
      owner: owner,
      rootTokenContract: rootTokenContract,
      group: tokenWallet.transport.connectionData.group,
      info: tokenWalletInfo,
    );

    return tokenWalletInfo;
  }

  Stream<TokenWalletInfo?> getInfoStream({
    required String owner,
    required String rootTokenContract,
  }) =>
      _tokenWalletsSubject
          .asyncMap(
            (e) async => e.asyncFirstWhere(
              (e) async => await e.owner == owner && (await e.symbol).rootTokenContract == rootTokenContract,
            ),
          )
          .flatMap((v) => v.balanceChangesStream.cast<String?>().startWith(null).map((e) => v))
          .asyncMap(
            (e) async {
              final tokenWalletInfo = TokenWalletInfo(
                owner: await e.owner,
                address: await e.address,
                symbol: await e.symbol,
                version: await e.version,
                balance: await e.balance,
                contractState: await e.contractState,
              );

              await _hiveSource.saveTokenWalletInfo(
                owner: owner,
                rootTokenContract: rootTokenContract,
                group: e.transport.connectionData.group,
                info: tokenWalletInfo,
              );

              return tokenWalletInfo;
            },
          )
          .cast<TokenWalletInfo?>()
          .onErrorReturn(null)
          .distinct();

  Stream<List<TokenWalletTransactionWithData>?> getTransactionsStream({
    required String owner,
    required String rootTokenContract,
  }) =>
      _tokenWalletsSubject
          .asyncMap(
            (e) async => e.asyncFirstWhere(
              (e) async => await e.owner == owner && (await e.symbol).rootTokenContract == rootTokenContract,
            ),
          )
          .flatMap(
            (v) => v.transactionsStream.map((e) => e.where((e) => e.data != null).toList()).asyncMap(
              (e) async {
                final group = v.transport.connectionData.group;

                final cached = _hiveSource.getTokenWalletTransactions(
                  owner: owner,
                  rootTokenContract: rootTokenContract,
                  group: group,
                );

                final list = [
                  ...{
                    if (cached != null) ...cached,
                    ...e,
                  }
                ]..sort((a, b) => a.transaction.compareTo(b.transaction));

                await _hiveSource.saveTokenWalletTransactions(
                  owner: owner,
                  rootTokenContract: rootTokenContract,
                  group: group,
                  transactions: list,
                );

                return list;
              },
            ),
          )
          .cast<List<TokenWalletTransactionWithData>?>()
          .onErrorReturn(null)
          .distinct((a, b) => listEquals(a, b));

  Future<InternalMessage> prepareTransfer({
    required String owner,
    required String rootTokenContract,
    required String destination,
    required String tokens,
    required bool notifyReceiver,
    String? payload,
  }) async {
    final tokenWallet = await _getTokenWallet(
      owner: owner,
      rootTokenContract: rootTokenContract,
    );

    final internalMessage = await tokenWallet.prepareTransfer(
      destination: destination,
      tokens: tokens,
      notifyReceiver: notifyReceiver,
      payload: payload,
    );

    return internalMessage;
  }

  Future<void> refresh({
    required String owner,
    required String rootTokenContract,
  }) async {
    final tokenWallet = await _getTokenWallet(
      owner: owner,
      rootTokenContract: rootTokenContract,
    );

    await tokenWallet.refresh();
  }

  Future<void> preloadTransactions({
    required String owner,
    required String rootTokenContract,
    required TransactionId from,
  }) async {
    final tokenWallet = await _getTokenWallet(
      owner: owner,
      rootTokenContract: rootTokenContract,
    );

    await tokenWallet.preloadTransactions(from);
  }

  Future<TokenWallet> _getTokenWallet({
    required String owner,
    required String rootTokenContract,
  }) =>
      _tokenWalletsSubject
          .asyncMap(
            (e) async => e.asyncFirstWhereOrNull(
              (e) async => await e.owner == owner && (await e.symbol).rootTokenContract == rootTokenContract,
            ),
          )
          .whereType<TokenWallet>()
          .first
          .timeout(
            kSubscriptionRefreshTimeout * 2,
            onTimeout: () => throw Exception('Token wallet not found'),
          );

  Future<void> _currentAccountsStreamListener(Tuple2<List<AssetsList>, Transport> event) async {
    try {
      final accounts = event.item1;
      final transport = event.item2;

      final networkGroup = transport.connectionData.group;

      final tokenWalletAssets = accounts
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

      final tokenWalletsForUnsubscription = await _tokenWalletsSubject.value.asyncWhere(
        (e) async =>
            e.transport != transport ||
            !await tokenWalletAssets
                .asyncAny((el) async => el.item1 == await e.owner && el.item2 == (await e.symbol).rootTokenContract),
      );

      for (final tokenWalletForUnsubscription in tokenWalletsForUnsubscription) {
        _tokenWalletsSubject.add(_tokenWalletsSubject.value.where((e) => e != tokenWalletForUnsubscription).toList());

        tokenWalletForUnsubscription.freePtr();
      }

      final tokenWalletAssetsForSubscription = await tokenWalletAssets.asyncWhere(
        (e) async => !await _tokenWalletsSubject.value
            .asyncAny((el) async => await el.owner == e.item1 && (await el.symbol).rootTokenContract == e.item2),
      );

      for (final tokenWalletAssetForSubscription in tokenWalletAssetsForSubscription) {
        try {
          final tokenWallet = await TokenWallet.subscribe(
            transport: transport,
            owner: tokenWalletAssetForSubscription.item1,
            rootTokenContract: tokenWalletAssetForSubscription.item2,
          );

          _tokenWalletsSubject.add([..._tokenWalletsSubject.value, tokenWallet]);
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

      final transport = await _transportSource.transport;

      final networkGroup = transport.connectionData.group;

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

      final removedTokenWallets = [...previousTokenWallets]
        ..removeWhere((e) => currentTokenWallets.any((el) => el.item1 == e.item1 && el.item2 == e.item2));

      for (final removedTokenWallet in removedTokenWallets) {
        await _hiveSource.removeTokenWalletInfo(
          owner: removedTokenWallet.item1,
          rootTokenContract: removedTokenWallet.item2,
        );
        await _hiveSource.removeTokenWalletTransactions(
          owner: removedTokenWallet.item1,
          rootTokenContract: removedTokenWallet.item2,
        );
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
