import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'transaction_id_dto.freezed.dart';
part 'transaction_id_dto.g.dart';

@freezed
class TransactionIdDto with _$TransactionIdDto {
  @HiveType(typeId: 23)
  const factory TransactionIdDto({
    @HiveField(0) required String lt,
    @HiveField(1) required String hash,
  }) = _TransactionIdDto;
}

extension TransactionIdDtoToDomain on TransactionIdDto {
  TransactionId toModel() => TransactionId(
        lt: lt,
        hash: hash,
      );
}

extension TransactionIdFromDomain on TransactionId {
  TransactionIdDto toDto() => TransactionIdDto(
        lt: lt,
        hash: hash,
      );
}
