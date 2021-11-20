import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'ton_wallet_transactions.freezed.dart';

@freezed
class TonWalletTransactions with _$TonWalletTransactions {
  const factory TonWalletTransactions({
    @Default([]) List<TonWalletTransactionWithData> ordinary,
    @Default([]) List<Transaction> sent,
    @Default([]) List<Transaction> expired,
  }) = _TonWalletTransactions;
}
