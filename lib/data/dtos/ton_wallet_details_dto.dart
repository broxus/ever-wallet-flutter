import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'ton_wallet_details_dto.freezed.dart';
part 'ton_wallet_details_dto.g.dart';

@freezed
class TonWalletDetailsDto with _$TonWalletDetailsDto {
  @HiveType(typeId: 8)
  const factory TonWalletDetailsDto({
    @HiveField(0) required bool requiresSeparateDeploy,
    @HiveField(1) required String minAmount,
    @HiveField(2) required bool supportsPayload,
    @HiveField(3) required bool supportsMultipleOwners,
    @HiveField(4) required int expirationTime,
  }) = _TonWalletDetailsDto;
}

extension TonWalletDetailsDtoToDomain on TonWalletDetailsDto {
  TonWalletDetails toModel() => TonWalletDetails(
        requiresSeparateDeploy: requiresSeparateDeploy,
        minAmount: minAmount,
        supportsPayload: supportsPayload,
        supportsMultipleOwners: supportsMultipleOwners,
        expirationTime: expirationTime,
      );
}

extension TonWalletDetailsFromDomain on TonWalletDetails {
  TonWalletDetailsDto toDto() => TonWalletDetailsDto(
        requiresSeparateDeploy: requiresSeparateDeploy,
        minAmount: minAmount,
        supportsPayload: supportsPayload,
        supportsMultipleOwners: supportsMultipleOwners,
        expirationTime: expirationTime,
      );
}
