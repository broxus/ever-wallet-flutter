import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/transaction_additional_info_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/transaction_dto.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'ton_wallet_transaction_with_data_dto.freezed.dart';
part 'ton_wallet_transaction_with_data_dto.g.dart';

@freezedDto
class TonWalletTransactionWithDataDto with _$TonWalletTransactionWithDataDto {
  @HiveType(typeId: 38)
  const factory TonWalletTransactionWithDataDto({
    @HiveField(0) required TransactionDto transaction,
    @HiveField(1) TransactionAdditionalInfoDto? data,
  }) = _TonWalletTransactionWithDataDto;
}

extension TonWalletTransactionWithDataX on TonWalletTransactionWithData {
  TonWalletTransactionWithDataDto toDto() => TonWalletTransactionWithDataDto(
        transaction: transaction.toDto(),
        data: data?.toDto(),
      );
}

extension TonWalletTransactionWithDataDtoX on TonWalletTransactionWithDataDto {
  TonWalletTransactionWithData toModel() => TonWalletTransactionWithData(
        transaction: transaction.toModel(),
        data: data?.toModel(),
      );
}
