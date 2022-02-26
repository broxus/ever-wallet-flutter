import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tuple/tuple.dart';

import '../../logger.dart';
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
    _transportSource.transportStream
        .skip(1)
        .whereType<Transport>()
        .listen((event) => _lock.synchronized(() => _transportStreamListener()));

    _accountsStorageSource.currentAccountsStream
        .startWith(const [])
        .pairwise()
        .listen((event) => _lock.synchronized(() => _currentAccountsStreamListener(event)));

    _accountsStorageSource.accountsStream
        .skip(1)
        .startWith(const [])
        .pairwise()
        .listen((event) => _lock.synchronized(() => _accountsStreamListener(event)));
  }

  Stream<TokenWalletInfo> getInfoStream({
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
          .flatMap((v) => v.onBalanceChangedStream.map((e) => v))
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

              await _hiveSource.saveTokenWalletInfo(tokenWalletInfo);

              return tokenWalletInfo;
            },
          )
          .whereType<TokenWalletInfo?>()
          .startWith(
            _hiveSource.getTokenWalletInfo(
              owner: owner,
              rootTokenContract: rootTokenContract,
            ),
          )
          .whereType<TokenWalletInfo>();

  Stream<String> getBalanceChangesStream({
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
          .flatMap((v) => v.onBalanceChangedStream.map((e) => e.balance));

  Stream<List<TokenWalletTransactionWithData>> getTransactionsStream({
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
          .flatMap((v) => v.onTransactionsFoundStream)
          .cast<OnTokenWalletTransactionsFoundPayload?>()
          .startWith(null)
          .pairwise()
          .asyncMap(
            (e) async {
              final prev = e.first;
              final next = e.last;

              final transactions = [
                ...prev?.transactions ?? <TokenWalletTransactionWithData>[],
                ...next?.transactions ?? <TokenWalletTransactionWithData>[],
              ]..sort((a, b) => a.transaction.compareTo(b.transaction));

              await _hiveSource.saveTokenWalletTransactions(
                owner: owner,
                rootTokenContract: rootTokenContract,
                transactions: transactions,
              );

              return transactions;
            },
          )
          .whereType<List<TokenWalletTransactionWithData>?>()
          .startWith(
            _hiveSource.getTokenWalletTransactions(
              owner: owner,
              rootTokenContract: rootTokenContract,
            ),
          )
          .whereType<List<TokenWalletTransactionWithData>>();

  Future<InternalMessage> prepareTransfer({
    required String owner,
    required String rootTokenContract,
    required String destination,
    required String tokens,
    required bool notifyReceiver,
    String? payload,
  }) async {
    final tokenWallet = await _tokenWalletsSubject.value.asyncFirstWhereOrNull(
      (e) async => await e.owner == owner && (await e.symbol).rootTokenContract == rootTokenContract,
    );

    if (tokenWallet == null) throw Exception('Token wallet not found');

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
    final tokenWallet = await _tokenWalletsSubject.value.asyncFirstWhereOrNull(
      (e) async => await e.owner == owner && (await e.symbol).rootTokenContract == rootTokenContract,
    );

    if (tokenWallet == null) throw Exception('Token wallet not found');

    await tokenWallet.refresh();
  }

  Future<void> preloadTransactions({
    required String owner,
    required String rootTokenContract,
    required TransactionId from,
  }) async {
    final tokenWallet = await _tokenWalletsSubject.value.asyncFirstWhereOrNull(
      (e) async => await e.owner == owner && (await e.symbol).rootTokenContract == rootTokenContract,
    );

    if (tokenWallet == null) throw Exception('Token wallet not found');

    await tokenWallet.preloadTransactions(from);
  }

  Future<TokenWallet> _subscribe({
    required String owner,
    required String rootTokenContract,
  }) async {
    var tokenWallet = await _tokenWalletsSubject.value.asyncFirstWhereOrNull(
      (e) async => await e.owner == owner && (await e.symbol).rootTokenContract == rootTokenContract,
    );

    if (tokenWallet != null) return tokenWallet;

    final transport = _transportSource.transport;

    if (transport == null) throw Exception('Transport unavailable');

    tokenWallet = await TokenWallet.subscribe(
      transport: transport,
      owner: owner,
      rootTokenContract: rootTokenContract,
    );

    _tokenWalletsSubject.add([..._tokenWalletsSubject.value, tokenWallet]);

    return tokenWallet;
  }

  Future<void> _unsubscribe({
    required String owner,
    required String rootTokenContract,
  }) async {
    final tokenWallet = await _tokenWalletsSubject.value.asyncFirstWhereOrNull(
      (e) async => await e.owner == owner && (await e.symbol).rootTokenContract == rootTokenContract,
    );

    if (tokenWallet == null) return;

    final tokenWallets = _tokenWalletsSubject.value.where((e) => e != tokenWallet).toList();

    _tokenWalletsSubject.add(tokenWallets);

    await tokenWallet.freePtr();
  }

  Future<void> _clear() async {
    final tokenWallets = [..._tokenWalletsSubject.value];

    _tokenWalletsSubject.add([]);

    for (final tokenWallet in tokenWallets) {
      await tokenWallet.freePtr();
    }
  }

  Future<void> _transportStreamListener() async {
    try {
      final tokenWallets = await _tokenWalletsSubject.value.asyncMap(
        (e) async => Tuple2(
          await e.owner,
          (await e.symbol).rootTokenContract,
        ),
      );

      await _clear();

      for (final tokenWallet in tokenWallets) {
        await _subscribe(
          owner: tokenWallet.item1,
          rootTokenContract: tokenWallet.item2,
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

      final transport = _transportSource.transport;

      if (transport == null) throw Exception('Transport unavailable');

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

      final addedTokenWallets = [...currentTokenWallets]
        ..removeWhere((e) => previousTokenWallets.any((el) => el.item1 == e.item1 && el.item2 == e.item2));
      final removedTokenWallets = [...previousTokenWallets]
        ..removeWhere((e) => currentTokenWallets.any((el) => el.item1 == e.item1 && el.item2 == e.item2));

      for (final addedTokenWallet in addedTokenWallets) {
        await _subscribe(
          owner: addedTokenWallet.item1,
          rootTokenContract: addedTokenWallet.item2,
        );
      }

      for (final removedTokenWallet in removedTokenWallets) {
        await _unsubscribe(
          owner: removedTokenWallet.item1,
          rootTokenContract: removedTokenWallet.item2,
        );
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<void> _accountsStreamListener(Iterable<List<AssetsList>> event) async {
    try {
      final prev = event.first;
      final next = event.last;

      final transport = _transportSource.transport;

      if (transport == null) throw Exception('Transport unavailable');

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
