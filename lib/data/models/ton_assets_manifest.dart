import 'package:freezed_annotation/freezed_annotation.dart';

import 'token_contract_asset.dart';
import 'ton_assets_manifest_version.dart';

part 'ton_assets_manifest.freezed.dart';
part 'ton_assets_manifest.g.dart';

@freezed
class TonAssetsManifestDto with _$TonAssetsManifestDto {
  @JsonSerializable(explicitToJson: true)
  const factory TonAssetsManifestDto({
    @JsonKey(name: '\$schema') required String schema,
    required String name,
    required TonAssetsManifestVersion version,
    required List<String> keywords,
    required String timestamp,
    required List<TokenContractAsset> tokens,
  }) = _TonAssetsManifestDto;

  factory TonAssetsManifestDto.fromJson(Map<String, dynamic> json) => _$TonAssetsManifestDtoFromJson(json);
}
