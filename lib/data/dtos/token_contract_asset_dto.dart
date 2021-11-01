import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/models/token_contract_asset.dart';

part 'token_contract_asset_dto.freezed.dart';
part 'token_contract_asset_dto.g.dart';

@freezed
class TokenContractAssetDto with _$TokenContractAssetDto {
  @HiveType(typeId: 1)
  const factory TokenContractAssetDto({
    @HiveField(0) required String name,
    @HiveField(1) int? chainId,
    @HiveField(2) required String symbol,
    @HiveField(3) required int decimals,
    @HiveField(4) required String address,
    @HiveField(5) String? svgIcon,
    @HiveField(6) List<int>? gravatarIcon,
    @HiveField(7) required int version,
  }) = _TokenContractAssetDto;
}

extension TokenContractAssetDtoToDomain on TokenContractAssetDto {
  TokenContractAsset toModel() => TokenContractAsset(
        name: name,
        chainId: chainId,
        symbol: symbol,
        decimals: decimals,
        address: address,
        svgIcon: svgIcon,
        gravatarIcon: gravatarIcon,
        version: version,
      );
}

extension TokenContractAssetFromDomain on TokenContractAsset {
  TokenContractAssetDto toDto() => TokenContractAssetDto(
        name: name,
        chainId: chainId,
        symbol: symbol,
        decimals: decimals,
        address: address,
        svgIcon: svgIcon,
        gravatarIcon: gravatarIcon,
        version: version,
      );
}
