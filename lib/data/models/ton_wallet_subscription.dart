import 'dart:async';

import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

typedef TonWalletOnMessageSent = void Function(Tuple2<PendingTransaction, Transaction?> event);
typedef TonWalletOnMessageExpired = void Function(PendingTransaction event);
typedef TonWalletOnStateChanged = void Function(ContractState event);
typedef TonWalletOnTransactionsFound = void Function(
  Tuple2<List<TransactionWithData<TransactionAdditionalInfo?>>, TransactionsBatchInfo> event,
);

class TonWalletSubscription {
  final TonWallet tonWallet;
  late final StreamSubscription<Tuple2<PendingTransaction, Transaction?>>
      _onMessageSentStreamSubscription;
  late final StreamSubscription<PendingTransaction> _onMessageExpiredStreamSubscription;
  late final StreamSubscription<ContractState> _onStateChangedStreamSubscription;
  late final StreamSubscription<
          Tuple2<List<TransactionWithData<TransactionAdditionalInfo?>>, TransactionsBatchInfo>>
      _onTransactionsFoundStreamSubscription;

  TonWalletSubscription._(this.tonWallet);

  static Future<TonWalletSubscription> subscribe({
    required TonWallet tonWallet,
    required TonWalletOnMessageSent onMessageSent,
    required TonWalletOnMessageExpired onMessageExpired,
    required TonWalletOnStateChanged onStateChanged,
    required TonWalletOnTransactionsFound onTransactionsFound,
  }) async {
    final instance = TonWalletSubscription._(tonWallet);
    await instance._initialize(
      onMessageSent: onMessageSent,
      onMessageExpired: onMessageExpired,
      onStateChanged: onStateChanged,
      onTransactionsFound: onTransactionsFound,
    );
    return instance;
  }

  Future<void> dispose() async {
    await tonWallet.dispose();
    await _onMessageSentStreamSubscription.cancel();
    await _onMessageExpiredStreamSubscription.cancel();
    await _onStateChangedStreamSubscription.cancel();
    await _onTransactionsFoundStreamSubscription.cancel();
  }

  Future<void> _initialize({
    required TonWalletOnMessageSent onMessageSent,
    required TonWalletOnMessageExpired onMessageExpired,
    required TonWalletOnStateChanged onStateChanged,
    required TonWalletOnTransactionsFound onTransactionsFound,
  }) async {
    _onMessageSentStreamSubscription = tonWallet.onMessageSentStream.listen(onMessageSent);
    _onMessageExpiredStreamSubscription = tonWallet.onMessageExpiredStream.listen(onMessageExpired);
    _onStateChangedStreamSubscription = tonWallet.onStateChangedStream.listen(onStateChanged);
    _onTransactionsFoundStreamSubscription =
        tonWallet.onTransactionsFoundStream.listen(onTransactionsFound);
  }
}
