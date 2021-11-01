import 'package:crystal/data/dtos/transaction_additional_info_dto.dart';
import 'package:crystal/data/dtos/transaction_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'ton_wallet_transaction_with_data_dto.freezed.dart';
part 'ton_wallet_transaction_with_data_dto.g.dart';

@freezed
class TonWalletTransactionWithDataDto with _$TonWalletTransactionWithDataDto {
  @HiveType(typeId: 40)
  const factory TonWalletTransactionWithDataDto({
    @HiveField(0) required TransactionDto transaction,
    @HiveField(1) TransactionAdditionalInfoDto? data,
  }) = _TonWalletTransactionWithDataDto;
}

extension TonWalletTransactionWithDataDtoToDomain on TonWalletTransactionWithDataDto {
  TonWalletTransactionWithData toModel() => TonWalletTransactionWithData(
        transaction: transaction.toModel(),
        data: data?.toModel(),
      );
}

extension TonWalletTransactionWithDataFromDomain on TonWalletTransactionWithData {
  TonWalletTransactionWithDataDto toDto() => TonWalletTransactionWithDataDto(
        transaction: transaction.toDto(),
        data: data?.toDto(),
      );
}
