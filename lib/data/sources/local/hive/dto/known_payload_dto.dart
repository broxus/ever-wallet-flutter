import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/token_outgoing_transfer_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/token_swap_back_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'known_payload_dto.freezed.dart';
part 'known_payload_dto.g.dart';

@freezedDto
class KnownPayloadDto with _$KnownPayloadDto {
  @HiveType(typeId: 10)
  const factory KnownPayloadDto.comment(@HiveField(0) String data) = _KnownPayloadDtoComment;

  @HiveType(typeId: 11)
  const factory KnownPayloadDto.tokenOutgoingTransfer(@HiveField(0) TokenOutgoingTransferDto data) =
      _KnownPayloadDtoTokenOutgoingTransfer;

  @HiveType(typeId: 12)
  const factory KnownPayloadDto.tokenSwapBack(@HiveField(0) TokenSwapBackDto data) =
      _KnownPayloadDtoTokenSwapBack;
}

extension KnownPayloadX on KnownPayload {
  KnownPayloadDto toDto() => when(
        comment: (data) => KnownPayloadDto.comment(data),
        tokenOutgoingTransfer: (data) => KnownPayloadDto.tokenOutgoingTransfer(data.toDto()),
        tokenSwapBack: (data) => KnownPayloadDto.tokenSwapBack(data.toDto()),
      );
}

extension KnownPayloadDtoX on KnownPayloadDto {
  KnownPayload toModel() => when(
        comment: (data) => KnownPayload.comment(data),
        tokenOutgoingTransfer: (data) => KnownPayload.tokenOutgoingTransfer(data.toModel()),
        tokenSwapBack: (data) => KnownPayload.tokenSwapBack(data.toModel()),
      );
}
