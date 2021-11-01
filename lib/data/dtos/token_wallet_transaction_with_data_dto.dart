import 'package:crystal/data/dtos/token_wallet_transaction_dto.dart';
import 'package:crystal/data/dtos/transaction_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'token_wallet_transaction_with_data_dto.freezed.dart';
part 'token_wallet_transaction_with_data_dto.g.dart';

@freezed
class TokenWalletTransactionWithDataDto with _$TokenWalletTransactionWithDataDto {
  @HiveType(typeId: 21)
  const factory TokenWalletTransactionWithDataDto({
    @HiveField(0) required TransactionDto transaction,
    @HiveField(1) TokenWalletTransactionDto? data,
  }) = _TokenWalletTransactionWithDataDto;
}

extension TokenWalletTransactionWithDataDtoToDomain on TokenWalletTransactionWithDataDto {
  TokenWalletTransactionWithData toModel() => TokenWalletTransactionWithData(
        transaction: transaction.toModel(),
        data: data?.toModel(),
      );
}

extension TokenWalletTransactionWithDataFromDomain on TokenWalletTransactionWithData {
  TokenWalletTransactionWithDataDto toDto() => TokenWalletTransactionWithDataDto(
        transaction: transaction.toDto(),
        data: data?.toDto(),
      );
}
