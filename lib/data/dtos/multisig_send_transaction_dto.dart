import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'multisig_send_transaction_dto.freezed.dart';
part 'multisig_send_transaction_dto.g.dart';

@freezed
class MultisigSendTransactionDto with _$MultisigSendTransactionDto {
  @HiveType(typeId: 33)
  const factory MultisigSendTransactionDto({
    @HiveField(0) required String dest,
    @HiveField(1) required String value,
    @HiveField(2) required bool bounce,
    @HiveField(3) required int flags,
    @HiveField(4) required String payload,
  }) = _MultisigSendTransactionDto;

  factory MultisigSendTransactionDto.fromJson(Map<String, dynamic> json) => _$MultisigSendTransactionDtoFromJson(json);
}

extension MultisigSendTransactionDtoToDomain on MultisigSendTransactionDto {
  MultisigSendTransaction toModel() => MultisigSendTransaction(
        dest: dest,
        value: value,
        bounce: bounce,
        flags: flags,
        payload: payload,
      );
}

extension MultisigSendTransactionFromDomain on MultisigSendTransaction {
  MultisigSendTransactionDto toDto() => MultisigSendTransactionDto(
        dest: dest,
        value: value,
        bounce: bounce,
        flags: flags,
        payload: payload,
      );
}
