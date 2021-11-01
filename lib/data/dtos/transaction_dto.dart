import 'package:crystal/data/dtos/account_status_dto.dart';
import 'package:crystal/data/dtos/message_dto.dart';
import 'package:crystal/data/dtos/transaction_id_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'transaction_dto.freezed.dart';
part 'transaction_dto.g.dart';

@freezed
class TransactionDto with _$TransactionDto {
  @HiveType(typeId: 22)
  const factory TransactionDto({
    @HiveField(0) required TransactionIdDto id,
    @HiveField(1) TransactionIdDto? prevTransactionId,
    @HiveField(2) required int createdAt,
    @HiveField(3) required bool aborted,
    @HiveField(4) int? exitCode,
    @HiveField(5) required AccountStatusDto origStatus,
    @HiveField(6) required AccountStatusDto endStatus,
    @HiveField(7) required String totalFees,
    @HiveField(8) required MessageDto inMessage,
    @HiveField(9) required List<MessageDto> outMessages,
  }) = _TransactionDto;
}

extension TransactionDtoToDomain on TransactionDto {
  Transaction toModel() => Transaction(
        id: id.toModel(),
        prevTransactionId: prevTransactionId?.toModel(),
        createdAt: createdAt,
        aborted: aborted,
        exitCode: exitCode,
        origStatus: origStatus.toModel(),
        endStatus: endStatus.toModel(),
        totalFees: totalFees,
        inMessage: inMessage.toModel(),
        outMessages: outMessages.map((e) => e.toModel()).toList(),
      );
}

extension TransactionFromDomain on Transaction {
  TransactionDto toDto() => TransactionDto(
        id: id.toDto(),
        prevTransactionId: prevTransactionId?.toDto(),
        createdAt: createdAt,
        aborted: aborted,
        exitCode: exitCode,
        origStatus: origStatus.toDto(),
        endStatus: endStatus.toDto(),
        totalFees: totalFees,
        inMessage: inMessage.toDto(),
        outMessages: outMessages.map((e) => e.toDto()).toList(),
      );
}
