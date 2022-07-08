import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/multisig_confirm_transaction_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/multisig_send_transaction_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/multisig_submit_transaction_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'multisig_transaction_dto.freezed.dart';
part 'multisig_transaction_dto.g.dart';

@freezedDto
class MultisigTransactionDto with _$MultisigTransactionDto {
  @HiveType(typeId: 18)
  const factory MultisigTransactionDto.send(@HiveField(0) MultisigSendTransactionDto data) =
      _MultisigTransactionDtoSend;

  @HiveType(typeId: 19)
  const factory MultisigTransactionDto.submit(@HiveField(0) MultisigSubmitTransactionDto data) =
      _MultisigTransactionDtoSubmit;

  @HiveType(typeId: 20)
  const factory MultisigTransactionDto.confirm(@HiveField(0) MultisigConfirmTransactionDto data) =
      _MultisigTransactionDtoConfirm;
}

extension MultisigTransactionX on MultisigTransaction {
  MultisigTransactionDto toDto() => when(
        send: (data) => MultisigTransactionDto.send(data.toDto()),
        submit: (data) => MultisigTransactionDto.submit(data.toDto()),
        confirm: (data) => MultisigTransactionDto.confirm(data.toDto()),
      );
}

extension MultisigTransactionDtoX on MultisigTransactionDto {
  MultisigTransaction toModel() => when(
        send: (data) => MultisigTransaction.send(data.toModel()),
        submit: (data) => MultisigTransaction.submit(data.toModel()),
        confirm: (data) => MultisigTransaction.confirm(data.toModel()),
      );
}
