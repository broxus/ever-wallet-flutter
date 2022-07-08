import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/token_wallet_transaction_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/transaction_dto.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'token_wallet_transaction_with_data_dto.freezed.dart';
part 'token_wallet_transaction_with_data_dto.g.dart';

@freezedDto
class TokenWalletTransactionWithDataDto with _$TokenWalletTransactionWithDataDto {
  @HiveType(typeId: 34)
  const factory TokenWalletTransactionWithDataDto({
    @HiveField(0) required TransactionDto transaction,
    @HiveField(1) TokenWalletTransactionDto? data,
  }) = _TokenWalletTransactionWithDataDto;
}

extension TokenWalletTransactionWithDataX on TokenWalletTransactionWithData {
  TokenWalletTransactionWithDataDto toDto() => TokenWalletTransactionWithDataDto(
        transaction: transaction.toDto(),
        data: data?.toDto(),
      );
}

extension TokenWalletTransactionWithDataDtoX on TokenWalletTransactionWithDataDto {
  TokenWalletTransactionWithData toModel() => TokenWalletTransactionWithData(
        transaction: transaction.toModel(),
        data: data?.toModel(),
      );
}
