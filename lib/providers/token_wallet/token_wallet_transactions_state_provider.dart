import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../injection.dart';
import '../../data/repositories/token_wallets_repository.dart';
import 'token_wallet_transactions_provider.dart';

final tokenWalletTransactionsStateProvider = StateNotifierProvider.autoDispose.family<TokenWalletTransactionsNotifier,
    Tuple2<List<TokenWalletTransactionWithData>, bool>, Tuple2<String, String>>((ref, params) {
  final owner = params.item1;
  final rootTokenContract = params.item2;

  final notifier = TokenWalletTransactionsNotifier(ref.read, owner, rootTokenContract);

  ref.onDispose(
    ref.listen<AsyncValue<List<TokenWalletTransactionWithData>>>(
      tokenWalletTransactionsProvider(params),
      notifier.callback,
      fireImmediately: true,
    ),
  );

  return notifier;
});

class TokenWalletTransactionsNotifier extends StateNotifier<Tuple2<List<TokenWalletTransactionWithData>, bool>> {
  final Reader read;
  final String owner;
  final String rootTokenContract;

  TokenWalletTransactionsNotifier(
    this.read,
    this.owner,
    this.rootTokenContract,
  ) : super(const Tuple2([], false));

  Future<void> preload() async {
    final prevTransactionId = state.item1.lastOrNull?.transaction.prevTransactionId;

    if (prevTransactionId != null) {
      state = Tuple2([...state.item1], true);

      await getIt.get<TokenWalletsRepository>().preloadTransactions(
            owner: owner,
            rootTokenContract: rootTokenContract,
            from: prevTransactionId,
          );
    }
  }

  void callback(
    AsyncValue<List<TokenWalletTransactionWithData>>? previous,
    AsyncValue<List<TokenWalletTransactionWithData>> next,
  ) {
    state = Tuple2([...next.asData?.value ?? []], false);
  }
}
