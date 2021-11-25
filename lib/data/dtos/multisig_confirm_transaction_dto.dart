import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'multisig_confirm_transaction_dto.freezed.dart';
part 'multisig_confirm_transaction_dto.g.dart';

@freezed
class MultisigConfirmTransactionDto with _$MultisigConfirmTransactionDto {
  @HiveType(typeId: 32)
  const factory MultisigConfirmTransactionDto({
    @HiveField(0) required String custodian,
    @HiveField(1) required String transactionId,
  }) = _MultisigConfirmTransactionDto;

  factory MultisigConfirmTransactionDto.fromJson(Map<String, dynamic> json) =>
      _$MultisigConfirmTransactionDtoFromJson(json);
}

extension MultisigConfirmTransactionDtoToDomain on MultisigConfirmTransactionDto {
  MultisigConfirmTransaction toModel() => MultisigConfirmTransaction(
        custodian: custodian,
        transactionId: transactionId,
      );
}

extension MultisigConfirmTransactionFromDomain on MultisigConfirmTransaction {
  MultisigConfirmTransactionDto toDto() => MultisigConfirmTransactionDto(
        custodian: custodian,
        transactionId: transactionId,
      );
}
