import 'dart:async';

import 'package:collection/collection.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/models/token_wallet_info.dart';
import 'package:ever_wallet/data/sources/local/current_accounts_source.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/data/sources/remote/transport_source.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tuple/tuple.dart';

class TokenWalletsRepository {
  final _lock = Lock();
  final AccountsStorage _accountsStorage;
  final CurrentAccountsSource _currentAccountsSource;
  final TransportSource _transportSource;
  final HiveSource _hiveSource;
  final _tokenWalletsSubject = BehaviorSubject<List<TokenWallet>>.seeded([]);
  late final StreamSubscription _currentAccountsStreamSubscription;
  late final StreamSubscription _accountsStreamSubscription;

  TokenWalletsRepository(
    this._accountsStorage,
    this._currentAccountsSource,
    this._transportSource,
    this._hiveSource,
  ) {
    _currentAccountsStreamSubscription =
        Rx.combineLatest3<List<AssetsList>, Transport, void, Tuple2<List<AssetsList>, Transport>>(
      _currentAccountsSource.currentAccountsStream,
      _transportSource.transportStream,
      Stream<void>.periodic(kSubscriptionRefreshTimeout).startWith(null),
      (a, b, c) => Tuple2(a, b),
    ).listen((event) => _lock.synchronized(() => _currentAccountsStreamListener(event)));

    _accountsStreamSubscription = _accountsStorage.entriesStream
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
      owner: tokenWallet.owner,
      address: tokenWallet.address,
      symbol: tokenWallet.symbol,
      version: tokenWallet.version,
      balance: await tokenWallet.balance,
      contractState: await tokenWallet.contractState,
    );

    await _hiveSource.saveTokenWalletInfo(
      owner: owner,
      rootTokenContract: rootTokenContract,
      group: tokenWallet.transport.group,
      info: tokenWalletInfo,
    );

    return tokenWalletInfo;
  }

  Stream<TokenWalletInfo?> getInfoStream({
    required String owner,
    required String rootTokenContract,
  }) =>
      _tokenWalletsSubject
          .map(
            (e) => e.firstWhere(
              (e) => e.owner == owner && (e.symbol).rootTokenContract == rootTokenContract,
            ),
          )
          .flatMap(
            (v) => v.onBalanceChangedStream
                .map((e) => e.balance)
                .cast<String?>()
                .startWith(null)
                .map((e) => v),
          )
          .asyncMap(
            (e) async {
              final tokenWalletInfo = TokenWalletInfo(
                owner: e.owner,
                address: e.address,
                symbol: e.symbol,
                version: e.version,
                balance: await e.balance,
                contractState: await e.contractState,
              );

              await _hiveSource.saveTokenWalletInfo(
                owner: owner,
                rootTokenContract: rootTokenContract,
                group: e.transport.group,
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
          .map(
            (e) => e.firstWhere(
              (e) => e.owner == owner && (e.symbol).rootTokenContract == rootTokenContract,
            ),
          )
          .flatMap(
            (v) =>
                v.transactionsStream.map((e) => e.where((e) => e.data != null).toList()).asyncMap(
              (e) async {
                final group = v.transport.group;

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
    required String fromLt,
  }) async {
    final tokenWallet = await _getTokenWallet(
      owner: owner,
      rootTokenContract: rootTokenContract,
    );

    await tokenWallet.preloadTransactions(fromLt);
  }

  Future<void> dispose() async {
    await _currentAccountsStreamSubscription.cancel();
    await _accountsStreamSubscription.cancel();

    await _tokenWalletsSubject.close();
  }

  Future<TokenWallet> _getTokenWallet({
    required String owner,
    required String rootTokenContract,
  }) =>
      _tokenWalletsSubject
          .map(
            (e) => e.firstWhereOrNull(
              (e) => e.owner == owner && (e.symbol).rootTokenContract == rootTokenContract,
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

      final networkGroup = transport.group;

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

      final tokenWalletsForUnsubscription = _tokenWalletsSubject.value.where(
        (e) =>
            e.transport != transport ||
            !tokenWalletAssets.any(
              (el) => el.item1 == e.owner && el.item2 == (e.symbol).rootTokenContract,
            ),
      );

      for (final tokenWalletForUnsubscription in tokenWalletsForUnsubscription) {
        _tokenWalletsSubject.add(
          _tokenWalletsSubject.value.where((e) => e != tokenWalletForUnsubscription).toList(),
        );

        tokenWalletForUnsubscription.dispose();
      }

      final tokenWalletAssetsForSubscription = tokenWalletAssets.where(
        (e) => !_tokenWalletsSubject.value.any(
          (el) => el.owner == e.item1 && (el.symbol).rootTokenContract == e.item2,
        ),
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

      final networkGroup = transport.group;

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

      final removedTokenWallets = [...previousTokenWallets]..removeWhere(
          (e) => currentTokenWallets.any((el) => el.item1 == e.item1 && el.item2 == e.item2),
        );

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
