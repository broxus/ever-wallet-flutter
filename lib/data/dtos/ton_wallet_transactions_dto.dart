import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/models/ton_wallet_transactions.dart';
import 'ton_wallet_transaction_with_data_dto.dart';
import 'transaction_dto.dart';

part 'ton_wallet_transactions_dto.freezed.dart';
part 'ton_wallet_transactions_dto.g.dart';

@freezed
class TonWalletTransactionsDto with _$TonWalletTransactionsDto {
  @HiveType(typeId: 51)
  const factory TonWalletTransactionsDto({
    @HiveField(0) @Default([]) List<TonWalletTransactionWithDataDto> ordinary,
    @HiveField(1) @Default([]) List<TransactionDto> sent,
    @HiveField(2) @Default([]) List<TransactionDto> expired,
  }) = _TonWalletTransactionsDto;
}

extension TonWalletTransactionsDtoToDomain on TonWalletTransactionsDto {
  TonWalletTransactions toModel() => TonWalletTransactions(
        ordinary: ordinary.map((e) => e.toModel()).toList(),
        sent: sent.map((e) => e.toModel()).toList(),
        expired: expired.map((e) => e.toModel()).toList(),
      );
}

extension TonWalletTransactionsFromDomain on TonWalletTransactions {
  TonWalletTransactionsDto toDto() => TonWalletTransactionsDto(
        ordinary: ordinary.map((e) => e.toDto()).toList(),
        sent: sent.map((e) => e.toDto()).toList(),
        expired: expired.map((e) => e.toDto()).toList(),
      );
}
