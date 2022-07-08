import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'last_transaction_id_dto.freezed.dart';
part 'last_transaction_id_dto.g.dart';

@freezedDto
class LastTransactionIdDto with _$LastTransactionIdDto {
  @HiveType(typeId: 13)
  const factory LastTransactionIdDto({
    @HiveField(0) required bool isExact,
    @HiveField(1) required String lt,
    @HiveField(2) String? hash,
  }) = _LastTransactionIdDto;
}

extension LastTransactionIdX on LastTransactionId {
  LastTransactionIdDto toDto() => LastTransactionIdDto(
        isExact: isExact,
        lt: lt,
        hash: hash,
      );
}

extension LastTransactionIdDtoX on LastTransactionIdDto {
  LastTransactionId toModel() => LastTransactionId(
        isExact: isExact,
        lt: lt,
        hash: hash,
      );
}
