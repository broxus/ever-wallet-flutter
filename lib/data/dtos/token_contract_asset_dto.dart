import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/models/token_contract_asset.dart';

part 'token_contract_asset_dto.freezed.dart';
part 'token_contract_asset_dto.g.dart';

@freezed
@HiveType(typeId: 1)
class TokenContractAssetDto with _$TokenContractAssetDto {
  const factory TokenContractAssetDto({
    @HiveField(0) required String name,
    @HiveField(1) int? chainId,
    @HiveField(2) required String fullName,
    @HiveField(3) required int decimals,
    @HiveField(4) required String address,
    @HiveField(5) String? logoURI,
    @HiveField(6) required int version,
  }) = _TokenContractAssetDto;

  factory TokenContractAssetDto.fromJson(Map<String, dynamic> json) => _$TokenContractAssetDtoFromJson(json);

  factory TokenContractAssetDto.fromDomain(TokenContractAsset tokenContractAsset) => TokenContractAssetDto(
        name: tokenContractAsset.name,
        chainId: tokenContractAsset.chainId,
        fullName: tokenContractAsset.fullName,
        decimals: tokenContractAsset.decimals,
        address: tokenContractAsset.address,
        logoURI: tokenContractAsset.logoURI,
        version: tokenContractAsset.version,
      );

  const TokenContractAssetDto._();

  TokenContractAsset toDomain() => TokenContractAsset(
        name: name,
        chainId: chainId,
        fullName: fullName,
        decimals: decimals,
        address: address,
        logoURI: logoURI,
        version: version,
      );
}
