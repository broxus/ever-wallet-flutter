import 'dart:async';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/models/token_wallet_ordinary_transaction.dart';
import 'package:ever_wallet/data/models/token_wallet_pending_subscription_collection.dart';
import 'package:ever_wallet/data/models/token_wallet_subscription.dart';
import 'package:ever_wallet/data/sources/local/app_lifecycle_state_source.dart';
import 'package:ever_wallet/data/sources/local/current_accounts_source.dart';
import 'package:ever_wallet/data/sources/local/sqlite/sqlite_database.dart' as sql;
import 'package:ever_wallet/data/sources/remote/transport_source.dart';
import 'package:ever_wallet/logger.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tuple/tuple.dart';

class TokenWalletsRepository {
  final _lock = Lock();
  final sql.SqliteDatabase _sqliteDatabase;

  final TransportSource _transportSource;
  final CurrentAccountsSource _currentAccountsSource;
  final AppLifecycleStateSource _appLifecycleStateSource;
  final Map<TokenWalletPendingSubscriptionCollection, Completer<TokenWalletSubscription>>
      _pendingTokenWalletSubscriptions = {};
  final _tokenWalletsSubject =
      BehaviorSubject<Map<Tuple2<String, String>, Completer<TokenWalletSubscription>>>.seeded({});
  late final Timer _pollingTimer;
  late final StreamSubscription _currentAccountsStreamSubscription;
  late final StreamSubscription _transportStreamSubscription;

  TokenWalletsRepository({
    required sql.SqliteDatabase sqliteDatabase,
    required TransportSource transportSource,
    required CurrentAccountsSource currentAccountsSource,
    required AppLifecycleStateSource appLifecycleStateSource,
  })  : _sqliteDatabase = sqliteDatabase,
        _transportSource = transportSource,
        _currentAccountsSource = currentAccountsSource,
        _appLifecycleStateSource = appLifecycleStateSource {
    _pollingTimer = Timer.periodic(kSubscriptionRefreshTimeout, _pollingTimerCallback);

    _currentAccountsStreamSubscription = _currentAccountsSource.currentAccountsStream
        .listen((e) => _lock.synchronized(() => _currentAccountsStreamListener(e)));

    _transportStreamSubscription = _transportSource.transportStream
        .listen((e) => _lock.synchronized(() => _transportStreamListener(e)));
  }

  Stream<List<TokenWalletOrdinaryTransaction>> ordinaryTransactionsStream({
    required String owner,
    required String rootTokenContract,
  }) =>
      _tokenWalletsSubject.map((e) => e[Tuple2(owner, rootTokenContract)]).whereNotNull().flatMap(
            (e) => e.future.asStream().flatMap(
                  (e) => _sqliteDatabase.tokenWalletTransactionsDao
                      .transactions(
                        networkId: e.tokenWallet.transport.networkId,
                        group: e.tokenWallet.transport.group,
                        owner: e.tokenWallet.owner,
                        rootTokenContract: e.tokenWallet.symbol.rootTokenContract,
                      )
                      .map(
                        (el) => _mapOrdinaryTransactions(
                          tokenWallet: e.tokenWallet,
                          transactions: el,
                        ),
                      ),
                ),
          );

  Stream<String> balanceStream({
    required String owner,
    required String rootTokenContract,
  }) =>
      tokenWalletStream(
        owner: owner,
        rootTokenContract: rootTokenContract,
      ).flatMap((v) => v.onBalanceChangedStream.startWith(v.balance));

  Future<String> balance({
    required String owner,
    required String rootTokenContract,
  }) async {
    final tokenWallet = await _tokenWallet(
      owner: owner,
      rootTokenContract: rootTokenContract,
    );

    return tokenWallet.balance;
  }

  Stream<Symbol> symbolStream({
    required String owner,
    required String rootTokenContract,
  }) =>
      tokenWalletStream(
        owner: owner,
        rootTokenContract: rootTokenContract,
      ).flatMap((v) => v.onBalanceChangedStream.map((_) => v.symbol).startWith(v.symbol));

  Future<Symbol> symbol({
    required String owner,
    required String rootTokenContract,
  }) async {
    final tokenWallet = await _tokenWallet(
      owner: owner,
      rootTokenContract: rootTokenContract,
    );

    return tokenWallet.symbol;
  }

  Future<InternalMessage> prepareTransfer({
    required String owner,
    required String rootTokenContract,
    required String destination,
    required String tokens,
    required bool notifyReceiver,
    String? payload,
  }) async {
    final tokenWallet = await _tokenWallet(
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
    final tokenWallet = await _tokenWallet(
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
    final tokenWallet = await _tokenWallet(
      owner: owner,
      rootTokenContract: rootTokenContract,
    );

    await tokenWallet.preloadTransactions(fromLt);
  }

  Future<void> updateSubscription({
    required String owner,
    required String rootTokenContract,
  }) async =>
      _lock.synchronized(() async {
        final transport = _transportSource.transport;
        final subscriptions = {..._tokenWalletsSubject.value};

        await subscriptions[Tuple2(owner, rootTokenContract)]?.future.then((v) => v.dispose());

        final tuple = Tuple2(owner, rootTokenContract);

        final newCompleter = _subscribe(
          owner: owner,
          rootTokenContract: rootTokenContract,
          transport: transport,
        ).wrapInCompleter();
        _pendingTokenWalletSubscriptions[TokenWalletPendingSubscriptionCollection(
          asset: tuple,
          transportCollection: transport.toEquatableCollection(),
        )] = newCompleter;

        subscriptions[tuple] = newCompleter;

        _tokenWalletsSubject.add(subscriptions);
      });

  /// Create subscription to token if it's absent
  Future<void> updateSubscriptionIfAbsent({
    required String owner,
    required String rootTokenContract,
  }) async {
    final tuple = Tuple2(owner, rootTokenContract);
    if (_tokenWalletsSubject.value[tuple] == null) {
      return updateSubscription(owner: owner, rootTokenContract: rootTokenContract);
    }
  }

  Future<void> dispose() async {
    _pollingTimer.cancel();

    await _currentAccountsStreamSubscription.cancel();
    await _transportStreamSubscription.cancel();

    await _tokenWalletsSubject.close();

    for (final tonWallet in _tokenWalletsSubject.value.values) {
      tonWallet.future.then((v) => v.dispose()).ignore();
    }
  }

  void _pollingTimerCallback(Timer timer) {
    final appLifecycleState = _appLifecycleStateSource.appLifecycleState;
    final appIsActive = appLifecycleState == AppLifecycleState.resumed ||
        appLifecycleState == AppLifecycleState.inactive;

    if (appIsActive) {
      for (final tonWallet in _tokenWalletsSubject.value.values) {
        if (tonWallet.isCompleted) {
          tonWallet.future.then((v) async => v.tokenWallet.refresh()).ignore();
        }
      }
    }
  }

  void _currentAccountsStreamListener(List<AssetsList> event) {
    try {
      final transport = _transportSource.transport;
      final subscriptions = {..._tokenWalletsSubject.value};

      final networkGroup = transport.group;

      final tokenWallets = event
          .map(
            (e) => e.additionalAssets[networkGroup]?.tokenWallets.map(
              (el) => Tuple2(
                e.tonWallet.address,
                el.rootTokenContract,
              ),
            ),
          )
          .whereNotNull()
          .expand((e) => e);

      final tokenWalletsForUnsubscription = subscriptions.keys
          .where(
            (e) => !tokenWallets.any((el) => el == e),
          )
          .toList();

      for (final tuple in tokenWalletsForUnsubscription) {
        subscriptions.remove(tuple)!.future.then((v) => v.dispose()).ignore();
        final pendedKey = _pendingTokenWalletSubscriptions.keys
            .firstWhereOrNull((key) => key.asset.item1 == tuple.item1);
        if (pendedKey != null) {
          _pendingTokenWalletSubscriptions.remove(pendedKey);
        }
      }

      final tokenWalletsForSubscription = tokenWallets
          .where(
            (e) => !subscriptions.keys.any((el) => el == e),
          )
          .toList();

      for (final e in tokenWalletsForSubscription) {
        final completer = _subscribe(
          owner: e.item1,
          rootTokenContract: e.item2,
          transport: transport,
        ).wrapInCompleter();
        _pendingTokenWalletSubscriptions[TokenWalletPendingSubscriptionCollection(
          asset: e,
          transportCollection: transport.toEquatableCollection(),
        )] = completer;
        subscriptions[e] = completer;
      }
      _tokenWalletsSubject.add({...subscriptions});
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  void _transportStreamListener(Transport event) {
    try {
      final transport = event;

      final networkGroup = transport.group;

      final tokenWallets = _currentAccountsSource.currentAccounts
          .map(
            (e) => e.additionalAssets[networkGroup]?.tokenWallets.map(
              (el) => Tuple2(
                e.tonWallet.address,
                el.rootTokenContract,
              ),
            ),
          )
          .whereNotNull()
          .expand((e) => e);

      /// contains assets where transport is different to new one
      final assetsToRemove = tokenWallets.where((asset) {
        final pendingKey = TokenWalletPendingSubscriptionCollection(
          asset: asset,
          transportCollection: transport.toEquatableCollection(),
        );
        final pendedEntry =
            _pendingTokenWalletSubscriptions.entries.where((e) => e.key == pendingKey).firstOrNull;
        if (pendedEntry != null &&
            pendedEntry.key.isSameTransport(transport.toEquatableCollection())) {
          return false;
        }
        return true;
      });

      /// Unsubscribe
      for (final key in assetsToRemove) {
        _tokenWalletsSubject.value[key]!.future.then((v) => v.dispose()).ignore();
        _pendingTokenWalletSubscriptions.remove(
          TokenWalletPendingSubscriptionCollection(asset: key, transportCollection: []),
        );
      }

      final subscriptions = <Tuple2<String, String>, Completer<TokenWalletSubscription>>{};
      for (final e in tokenWallets) {
        final completer = _subscribe(
          owner: e.item1,
          rootTokenContract: e.item2,
          transport: transport,
        ).wrapInCompleter();
        _pendingTokenWalletSubscriptions[TokenWalletPendingSubscriptionCollection(
          asset: e,
          transportCollection: transport.toEquatableCollection(),
        )] = completer;
        subscriptions[e] = completer;
      }
      _tokenWalletsSubject.add(subscriptions);
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<TokenWalletSubscription> _subscribe({
    required String owner,
    required String rootTokenContract,
    required Transport transport,
  }) async {
    final pendingKey = TokenWalletPendingSubscriptionCollection(
      asset: Tuple2(owner, rootTokenContract),
      transportCollection: transport.toEquatableCollection(),
    );
    final pendedEntry =
        _pendingTokenWalletSubscriptions.entries.where((e) => e.key == pendingKey).firstOrNull;
    if (pendedEntry != null) {
      if (pendedEntry.key.isSameTransport(pendingKey.transportCollection)) {
        return pendedEntry.value.future;
      }
    }

    final tokenWallet = await TokenWallet.subscribe(
      transport: transport,
      owner: owner,
      rootTokenContract: rootTokenContract,
    );

    final subscription = TokenWalletSubscription.subscribe(
      tokenWallet: tokenWallet,
      onBalanceChanged: (e) async {
        await _sqliteDatabase.tokenWalletDetailsDao.updateSymbol(
          networkId: tokenWallet.transport.networkId,
          group: tokenWallet.transport.group,
          owner: tokenWallet.owner,
          rootTokenContract: tokenWallet.symbol.rootTokenContract,
          symbol: tokenWallet.symbol,
        );

        await _sqliteDatabase.tokenWalletDetailsDao.updateVersion(
          networkId: tokenWallet.transport.networkId,
          group: tokenWallet.transport.group,
          owner: tokenWallet.owner,
          rootTokenContract: tokenWallet.symbol.rootTokenContract,
          version: tokenWallet.version,
        );

        await _sqliteDatabase.tokenWalletDetailsDao.updateBalance(
          networkId: tokenWallet.transport.networkId,
          group: tokenWallet.transport.group,
          owner: tokenWallet.owner,
          rootTokenContract: tokenWallet.symbol.rootTokenContract,
          balance: e,
        );

        await _sqliteDatabase.tokenWalletDetailsDao.updateContractState(
          networkId: tokenWallet.transport.networkId,
          group: tokenWallet.transport.group,
          owner: tokenWallet.owner,
          rootTokenContract: tokenWallet.symbol.rootTokenContract,
          contractState: tokenWallet.contractState,
        );
      },
      onTransactionsFound: (e) async {
        await _sqliteDatabase.tokenWalletTransactionsDao.insertTransactions(
          networkId: tokenWallet.transport.networkId,
          group: tokenWallet.transport.group,
          owner: tokenWallet.owner,
          rootTokenContract: tokenWallet.symbol.rootTokenContract,
          transactions: e.item1,
        );
      },
    );

    return subscription;
  }

  Future<TokenWallet> _tokenWallet({
    required String owner,
    required String rootTokenContract,
  }) =>
      tokenWalletStream(owner: owner, rootTokenContract: rootTokenContract).first;

  Stream<TokenWallet> tokenWalletStream({
    required String owner,
    required String rootTokenContract,
  }) =>
      _tokenWalletsSubject.stream.where((v) => v[Tuple2(owner, rootTokenContract)] != null).flatMap(
            (value) => value[Tuple2(owner, rootTokenContract)]!
                .future
                .then((v) => v.tokenWallet)
                .asStream(),
          );

  List<TokenWalletOrdinaryTransaction> _mapOrdinaryTransactions({
    required TokenWallet tokenWallet,
    required List<TransactionWithData<TokenWalletTransaction?>> transactions,
  }) =>
      transactions.where((e) => e.data != null).map(
        (e) {
          final lt = e.transaction.id.lt;

          final prevTransactionLt = e.transaction.prevTransactionId?.lt;

          final sender = e.data!.maybeWhen(
                incomingTransfer: (tokenIncomingTransfer) => tokenIncomingTransfer.senderAddress,
                orElse: () => null,
              ) ??
              e.transaction.inMessage.src;

          final recipient = e.data!.maybeWhen(
                outgoingTransfer: (tokenOutgoingTransfer) => tokenOutgoingTransfer.to.data,
                orElse: () => null,
              ) ??
              e.transaction.outMessages.firstOrNull?.dst;

          final value = e.data!.when(
            incomingTransfer: (tokenIncomingTransfer) => tokenIncomingTransfer.tokens,
            outgoingTransfer: (tokenOutgoingTransfer) => tokenOutgoingTransfer.tokens,
            swapBack: (tokenSwapBack) => tokenSwapBack.tokens,
            accept: (data) => data,
            transferBounced: (data) => data,
            swapBackBounced: (data) => data,
          );

          final isOutgoing = e.data!.when(
            incomingTransfer: (tokenIncomingTransfer) => false,
            outgoingTransfer: (tokenOutgoingTransfer) => true,
            swapBack: (tokenSwapBack) => true,
            accept: (data) => false,
            transferBounced: (data) => false,
            swapBackBounced: (data) => false,
          );

          final address = (isOutgoing ? recipient : sender) ?? tokenWallet.address;

          final date = e.transaction.createdAt.toDateTime();

          final fees = e.transaction.totalFees;

          final hash = e.transaction.id.hash;

          TokenIncomingTransfer? incomingTransfer;

          TokenOutgoingTransfer? outgoingTransfer;

          TokenSwapBack? swapBack;

          String? accept;

          String? transferBounced;

          String? swapBackBounced;

          e.data!.when(
            incomingTransfer: (tokenIncomingTransfer) => incomingTransfer = tokenIncomingTransfer,
            outgoingTransfer: (tokenOutgoingTransfer) => outgoingTransfer = tokenOutgoingTransfer,
            swapBack: (tokenSwapBack) => swapBack = tokenSwapBack,
            accept: (data) => accept = data,
            transferBounced: (data) => transferBounced = data,
            swapBackBounced: (data) => swapBackBounced = data,
          );

          final transaction = TokenWalletOrdinaryTransaction(
            lt: lt,
            prevTransactionLt: prevTransactionLt,
            isOutgoing: isOutgoing,
            value: value,
            address: address,
            date: date,
            fees: fees,
            hash: hash,
            incomingTransfer: incomingTransfer,
            outgoingTransfer: outgoingTransfer,
            swapBack: swapBack,
            accept: accept,
            transferBounced: transferBounced,
            swapBackBounced: swapBackBounced,
          );

          return transaction;
        },
      ).toList();
}
