import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import 'multisig_confirm_transaction_dto.dart';
import 'multisig_send_transaction_dto.dart';
import 'multisig_submit_transaction_dto.dart';

part 'multisig_transaction_dto.freezed.dart';
part 'multisig_transaction_dto.g.dart';

@freezed
class MultisigTransactionDto with _$MultisigTransactionDto {
  @HiveType(typeId: 35)
  const factory MultisigTransactionDto.send({
    @HiveField(0) required MultisigSendTransactionDto multisigSendTransaction,
  }) = _Send;

  @HiveType(typeId: 36)
  const factory MultisigTransactionDto.submit({
    @HiveField(0) required MultisigSubmitTransactionDto multisigSubmitTransaction,
  }) = _Submit;

  @HiveType(typeId: 37)
  const factory MultisigTransactionDto.confirm({
    @HiveField(0) required MultisigConfirmTransactionDto multisigConfirmTransaction,
  }) = _Confirm;

  factory MultisigTransactionDto.fromJson(Map<String, dynamic> json) => _$MultisigTransactionDtoFromJson(json);
}

extension MultisigTransactionDtoToDomain on MultisigTransactionDto {
  MultisigTransaction toModel() => when(
        send: (multisigSendTransaction) => MultisigTransaction.send(
          multisigSendTransaction: multisigSendTransaction.toModel(),
        ),
        submit: (multisigSubmitTransaction) => MultisigTransaction.submit(
          multisigSubmitTransaction: multisigSubmitTransaction.toModel(),
        ),
        confirm: (multisigConfirmTransaction) => MultisigTransaction.confirm(
          multisigConfirmTransaction: multisigConfirmTransaction.toModel(),
        ),
      );
}

extension MultisigTransactionFromDomain on MultisigTransaction {
  MultisigTransactionDto toDto() => when(
        send: (multisigSendTransaction) => MultisigTransactionDto.send(
          multisigSendTransaction: multisigSendTransaction.toDto(),
        ),
        submit: (multisigSubmitTransaction) => MultisigTransactionDto.submit(
          multisigSubmitTransaction: multisigSubmitTransaction.toDto(),
        ),
        confirm: (multisigConfirmTransaction) => MultisigTransactionDto.confirm(
          multisigConfirmTransaction: multisigConfirmTransaction.toDto(),
        ),
      );
}
