import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'last_transaction_id_dto.freezed.dart';
part 'last_transaction_id_dto.g.dart';

@freezed
class LastTransactionIdDto with _$LastTransactionIdDto {
  @HiveType(typeId: 6)
  const factory LastTransactionIdDto({
    @HiveField(0) required bool isExact,
    @HiveField(1) required String lt,
    @HiveField(2) String? hash,
  }) = _LastTransactionIdDto;
}

extension LastTransactionIdDtoToDomain on LastTransactionIdDto {
  LastTransactionId toModel() => LastTransactionId(
        isExact: isExact,
        lt: lt,
        hash: hash,
      );
}

extension LastTransactionIdFromDomain on LastTransactionId {
  LastTransactionIdDto toDto() => LastTransactionIdDto(
        isExact: isExact,
        lt: lt,
        hash: hash,
      );
}
