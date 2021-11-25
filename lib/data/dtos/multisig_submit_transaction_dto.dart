import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'multisig_submit_transaction_dto.freezed.dart';
part 'multisig_submit_transaction_dto.g.dart';

@freezed
class MultisigSubmitTransactionDto with _$MultisigSubmitTransactionDto {
  @HiveType(typeId: 34)
  const factory MultisigSubmitTransactionDto({
    @HiveField(0) required String custodian,
    @HiveField(1) required String dest,
    @HiveField(2) required String value,
    @HiveField(3) required bool bounce,
    @HiveField(4) required bool allBalance,
    @HiveField(5) required String payload,
    @HiveField(6) required String transId,
  }) = _MultisigSubmitTransactionDto;

  factory MultisigSubmitTransactionDto.fromJson(Map<String, dynamic> json) =>
      _$MultisigSubmitTransactionDtoFromJson(json);
}

extension MultisigSubmitTransactionDtoToDomain on MultisigSubmitTransactionDto {
  MultisigSubmitTransaction toModel() => MultisigSubmitTransaction(
        custodian: custodian,
        dest: dest,
        value: value,
        bounce: bounce,
        allBalance: allBalance,
        payload: payload,
        transId: transId,
      );
}

extension MultisigSubmitTransactionFromDomain on MultisigSubmitTransaction {
  MultisigSubmitTransactionDto toDto() => MultisigSubmitTransactionDto(
        custodian: custodian,
        dest: dest,
        value: value,
        bounce: bounce,
        allBalance: allBalance,
        payload: payload,
        transId: transId,
      );
}
