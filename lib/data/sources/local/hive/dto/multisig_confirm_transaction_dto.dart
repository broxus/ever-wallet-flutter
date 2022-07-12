import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'multisig_confirm_transaction_dto.freezed.dart';
part 'multisig_confirm_transaction_dto.g.dart';

@freezedDto
class MultisigConfirmTransactionDto with _$MultisigConfirmTransactionDto {
  @HiveType(typeId: 15)
  const factory MultisigConfirmTransactionDto({
    @HiveField(0) required String custodian,
    @HiveField(1) required String transactionId,
  }) = _MultisigConfirmTransactionDto;
}

extension MultisigConfirmTransactionX on MultisigConfirmTransaction {
  MultisigConfirmTransactionDto toDto() => MultisigConfirmTransactionDto(
        custodian: custodian,
        transactionId: transactionId,
      );
}

extension MultisigConfirmTransactionDtoX on MultisigConfirmTransactionDto {
  MultisigConfirmTransaction toModel() => MultisigConfirmTransaction(
        custodian: custodian,
        transactionId: transactionId,
      );
}
