import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';
import 'ton_wallet_transactions_provider.dart';

final tonWalletTransactionsStateProvider = StateNotifierProvider.autoDispose
    .family<TonWalletTransactionsNotifier, Tuple2<List<TonWalletTransactionWithData>, bool>, String>((ref, address) {
  final notifier = TonWalletTransactionsNotifier(ref.read, address);

  ref.onDispose(
    ref.listen<AsyncValue<List<TonWalletTransactionWithData>>>(
      tonWalletTransactionsProvider(address),
      notifier.callback,
      fireImmediately: true,
    ),
  );

  return notifier;
});

class TonWalletTransactionsNotifier extends StateNotifier<Tuple2<List<TonWalletTransactionWithData>, bool>> {
  final Reader read;
  final String address;

  TonWalletTransactionsNotifier(
    this.read,
    this.address,
  ) : super(const Tuple2([], false));

  Future<void> preload() async {
    final prevTransactionId = state.item1.lastOrNull?.transaction.prevTransactionId;

    if (prevTransactionId != null) {
      state = Tuple2([...state.item1], true);

      final tonWallet = await getIt
          .get<NekotonService>()
          .tonWalletsStream
          .expand((e) => e)
          .firstWhere((e) => e.address == address)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw TonWalletNotFoundException(),
          );

      await tonWallet.preloadTransactions(prevTransactionId);
    }
  }

  void callback(
    AsyncValue<List<TonWalletTransactionWithData>>? previous,
    AsyncValue<List<TonWalletTransactionWithData>> next,
  ) {
    state = Tuple2([...next.asData?.value ?? []], false);
  }
}
