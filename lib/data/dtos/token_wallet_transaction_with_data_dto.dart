import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import 'token_wallet_transaction_dto.dart';
import 'transaction_dto.dart';

part 'token_wallet_transaction_with_data_dto.freezed.dart';
part 'token_wallet_transaction_with_data_dto.g.dart';

@freezed
class TokenWalletTransactionWithDataDto with _$TokenWalletTransactionWithDataDto {
  @HiveType(typeId: 21)
  const factory TokenWalletTransactionWithDataDto({
    @HiveField(0) required TransactionDto transaction,
    @HiveField(1) TokenWalletTransactionDto? data,
  }) = _TokenWalletTransactionWithDataDto;

  factory TokenWalletTransactionWithDataDto.fromJson(Map<String, dynamic> json) =>
      _$TokenWalletTransactionWithDataDtoFromJson(json);
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
