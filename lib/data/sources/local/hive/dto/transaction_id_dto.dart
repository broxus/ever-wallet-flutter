import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'transaction_id_dto.freezed.dart';
part 'transaction_id_dto.g.dart';

@freezedDto
class TransactionIdDto with _$TransactionIdDto {
  @HiveType(typeId: 45)
  const factory TransactionIdDto({
    @HiveField(0) required String lt,
    @HiveField(1) required String hash,
  }) = _TransactionIdDto;
}

extension TransactionIdX on TransactionId {
  TransactionIdDto toDto() => TransactionIdDto(
        lt: lt,
        hash: hash,
      );
}

extension TransactionIdDtoX on TransactionIdDto {
  TransactionId toModel() => TransactionId(
        lt: lt,
        hash: hash,
      );
}
