import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../injection.dart';
import '../../data/repositories/ton_wallets_repository.dart';
import '../../logger.dart';

final tonWalletTransactionsStateProvider = StateNotifierProvider.autoDispose
    .family<TonWalletTransactionsNotifier, Tuple2<List<TonWalletTransactionWithData>, bool>, String>(
  (ref, address) => TonWalletTransactionsNotifier(address),
);

class TonWalletTransactionsNotifier extends StateNotifier<Tuple2<List<TonWalletTransactionWithData>, bool>> {
  final String address;
  late final StreamSubscription _transactionsStreamSubscription;
  late final StreamSubscription _preloadStreamSubscription;
  final _preloadSubject = PublishSubject<TransactionId?>();

  TonWalletTransactionsNotifier(this.address) : super(const Tuple2([], false)) {
    _transactionsStreamSubscription = getIt
        .get<TonWalletsRepository>()
        .getTransactionsStream(address)
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

  void _transactionsStreamListener(List<TonWalletTransactionWithData>? event) => state = Tuple2(event ?? [], false);

  Future<void> _preloadStreamListener(TransactionId? event) async {
    try {
      if (event == null) return;

      await getIt.get<TonWalletsRepository>().preloadTransactions(
            address: address,
            from: event,
          );
    } catch (err, st) {
      logger.e(err, err, st);
    } finally {
      state = Tuple2([...state.item1], false);
    }
  }
}
