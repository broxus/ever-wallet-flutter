import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import 'token_outgoing_transfer_dto.dart';
import 'token_swap_back_dto.dart';

part 'known_payload_dto.freezed.dart';
part 'known_payload_dto.g.dart';

@freezed
class KnownPayloadDto with _$KnownPayloadDto {
  @HiveType(typeId: 29)
  const factory KnownPayloadDto.comment({
    @HiveField(0) required String value,
  }) = _Comment;

  @HiveType(typeId: 30)
  const factory KnownPayloadDto.tokenOutgoingTransfer({
    @HiveField(0) required TokenOutgoingTransferDto tokenOutgoingTransfer,
  }) = _TokenOutgoingTransfer;

  @HiveType(typeId: 31)
  const factory KnownPayloadDto.tokenSwapBack({
    @HiveField(0) required TokenSwapBackDto tokenSwapBack,
  }) = _TokenSwapBack;

  factory KnownPayloadDto.fromJson(Map<String, dynamic> json) => _$KnownPayloadDtoFromJson(json);
}

extension KnownPayloadDtoToDomain on KnownPayloadDto {
  KnownPayload toModel() => when(
        comment: (value) => KnownPayload.comment(
          value: value,
        ),
        tokenOutgoingTransfer: (tokenOutgoingTransfer) => KnownPayload.tokenOutgoingTransfer(
          tokenOutgoingTransfer: tokenOutgoingTransfer.toModel(),
        ),
        tokenSwapBack: (tokenSwapBack) => KnownPayload.tokenSwapBack(
          tokenSwapBack: tokenSwapBack.toModel(),
        ),
      );
}

extension KnownPayloadFromDomain on KnownPayload {
  KnownPayloadDto toDto() => when(
        comment: (value) => KnownPayloadDto.comment(
          value: value,
        ),
        tokenOutgoingTransfer: (tokenOutgoingTransfer) => KnownPayloadDto.tokenOutgoingTransfer(
          tokenOutgoingTransfer: tokenOutgoingTransfer.toDto(),
        ),
        tokenSwapBack: (tokenSwapBack) => KnownPayloadDto.tokenSwapBack(
          tokenSwapBack: tokenSwapBack.toDto(),
        ),
      );
}
