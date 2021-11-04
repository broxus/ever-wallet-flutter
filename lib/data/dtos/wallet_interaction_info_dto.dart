import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import 'known_payload_dto.dart';
import 'wallet_interaction_method_dto.dart';

part 'wallet_interaction_info_dto.freezed.dart';
part 'wallet_interaction_info_dto.g.dart';

@freezed
class WalletInteractionInfoDto with _$WalletInteractionInfoDto {
  @HiveType(typeId: 48)
  const factory WalletInteractionInfoDto({
    @HiveField(0) required String? recipient,
    @HiveField(1) required KnownPayloadDto? knownPayload,
    @HiveField(2) required WalletInteractionMethodDto method,
  }) = _WalletInteractionInfoDto;
}

extension WalletInteractionInfoDtoToDomain on WalletInteractionInfoDto {
  WalletInteractionInfo toModel() => WalletInteractionInfo(
        recipient: recipient,
        knownPayload: knownPayload?.toModel(),
        method: method.toModel(),
      );
}

extension WalletInteractionInfoFromDomain on WalletInteractionInfo {
  WalletInteractionInfoDto toDto() => WalletInteractionInfoDto(
        recipient: recipient,
        knownPayload: knownPayload?.toDto(),
        method: method.toDto(),
      );
}
