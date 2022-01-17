import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

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
    @HiveField(5) String? logoURI,
    @HiveField(6) required int version,
  }) = _TokenContractAssetDto;

  factory TokenContractAssetDto.fromJson(Map<String, dynamic> json) => _$TokenContractAssetDtoFromJson(json);
}
