import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'multisig_send_transaction_dto.freezed.dart';
part 'multisig_send_transaction_dto.g.dart';

@freezedDto
class MultisigSendTransactionDto with _$MultisigSendTransactionDto {
  @HiveType(typeId: 16)
  const factory MultisigSendTransactionDto({
    @HiveField(0) required String dest,
    @HiveField(1) required String value,
    @HiveField(2) required bool bounce,
    @HiveField(3) required int flags,
    @HiveField(4) required String payload,
  }) = _MultisigSendTransactionDto;
}

extension MultisigSendTransactionX on MultisigSendTransaction {
  MultisigSendTransactionDto toDto() => MultisigSendTransactionDto(
        dest: dest,
        value: value,
        bounce: bounce,
        flags: flags,
        payload: payload,
      );
}

extension MultisigSendTransactionDtoX on MultisigSendTransactionDto {
  MultisigSendTransaction toModel() => MultisigSendTransaction(
        dest: dest,
        value: value,
        bounce: bounce,
        flags: flags,
        payload: payload,
      );
}
