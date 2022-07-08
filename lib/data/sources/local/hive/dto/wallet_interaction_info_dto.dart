import 'package:ever_wallet/data/sources/local/hive/dto/known_payload_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/wallet_interaction_method_dto.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'wallet_interaction_info_dto.freezed.dart';
part 'wallet_interaction_info_dto.g.dart';

@freezedDto
class WalletInteractionInfoDto with _$WalletInteractionInfoDto {
  @HiveType(typeId: 48)
  const factory WalletInteractionInfoDto({
    @HiveField(0) String? recipient,
    @HiveField(1) KnownPayloadDto? knownPayload,
    @HiveField(2) required WalletInteractionMethodDto method,
  }) = _WalletInteractionInfoDto;
}

extension WalletInteractionInfoX on WalletInteractionInfo {
  WalletInteractionInfoDto toDto() => WalletInteractionInfoDto(
        recipient: recipient,
        knownPayload: knownPayload?.toDto(),
        method: method.toDto(),
      );
}

extension WalletInteractionInfoDtoX on WalletInteractionInfoDto {
  WalletInteractionInfo toModel() => WalletInteractionInfo(
        recipient: recipient,
        knownPayload: knownPayload?.toModel(),
        method: method.toModel(),
      );
}
