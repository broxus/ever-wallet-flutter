import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../injection.dart';
import '../../data/repositories/token_wallets_repository.dart';
import '../../logger.dart';

final tokenWalletTransactionsStateProvider = StateNotifierProvider.autoDispose.family<TokenWalletTransactionsNotifier,
    Tuple2<List<TokenWalletTransactionWithData>, bool>, Tuple2<String, String>>(
  (ref, params) => TokenWalletTransactionsNotifier(owner: params.item1, rootTokenContract: params.item2),
);

class TokenWalletTransactionsNotifier extends StateNotifier<Tuple2<List<TokenWalletTransactionWithData>, bool>> {
  final String owner;
  final String rootTokenContract;
  late final StreamSubscription _transactionsStreamSubscription;
  late final StreamSubscription _preloadStreamSubscription;
  final _preloadSubject = PublishSubject<TransactionId?>();

  TokenWalletTransactionsNotifier({
    required this.owner,
    required this.rootTokenContract,
  }) : super(const Tuple2([], false)) {
    _transactionsStreamSubscription = getIt
        .get<TokenWalletsRepository>()
        .getTransactionsStream(owner: owner, rootTokenContract: rootTokenContract)
        .listen((event) => _transactionsStreamListener(event));

    _preloadStreamSubscription = _preloadSubject
        .doOnData((e) {
          if (e != null && !state.item2) state = Tuple2([...state.item1], true);
        })
        .debounce((e) => TimerStream(e, const Duration(milliseconds: 300)))
        .listen((event) => _preloadStreamListener(event));
  }

  @override
  void dispose() {
    _transactionsStreamSubscription.cancel();
    _preloadStreamSubscription.cancel();
    super.dispose();
  }

  void preload(TransactionId? from) => _preloadSubject.add(from);

  void _transactionsStreamListener(List<TokenWalletTransactionWithData> event) => state = Tuple2(event, false);

  Future<void> _preloadStreamListener(TransactionId? event) async {
    try {
      if (event == null) return;

      await getIt.get<TokenWalletsRepository>().preloadTransactions(
            owner: owner,
            rootTokenContract: rootTokenContract,
            from: event,
          );
    } catch (err, st) {
      logger.e(err, err, st);
    } finally {
      state = Tuple2([...state.item1], false);
    }
  }
}
