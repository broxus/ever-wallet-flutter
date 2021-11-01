import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'token_incoming_transfer_dto.freezed.dart';
part 'token_incoming_transfer_dto.g.dart';

@freezed
class TokenIncomingTransferDto with _$TokenIncomingTransferDto {
  @HiveType(typeId: 12)
  const factory TokenIncomingTransferDto({
    @HiveField(0) required String tokens,
    @HiveField(1) required String senderAddress,
  }) = _TokenIncomingTransferDto;
}

extension TokenIncomingTransferDtoToDomain on TokenIncomingTransferDto {
  TokenIncomingTransfer toModel() => TokenIncomingTransfer(
        tokens: tokens,
        senderAddress: senderAddress,
      );
}

extension TokenIncomingTransferFromDomain on TokenIncomingTransfer {
  TokenIncomingTransferDto toDto() => TokenIncomingTransferDto(
        tokens: tokens,
        senderAddress: senderAddress,
      );
}
