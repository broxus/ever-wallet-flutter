import 'package:freezed_annotation/freezed_annotation.dart';

import 'ton_assets_manifest_token_dto.dart';
import 'ton_assets_manifest_version_dto.dart';

part 'ton_assets_manifest_dto.freezed.dart';
part 'ton_assets_manifest_dto.g.dart';

@freezed
class TonAssetsManifestDto with _$TonAssetsManifestDto {
  @JsonSerializable(explicitToJson: true)
  const factory TonAssetsManifestDto({
    @JsonKey(name: '\$schema') required String schema,
    required String name,
    required TonAssetsManifestVersionDto version,
    required List<String> keywords,
    required String timestamp,
    required List<TonAssetsManifestTokenDto> tokens,
  }) = _TonAssetsManifestDto;

  factory TonAssetsManifestDto.fromJson(Map<String, dynamic> json) => _$TonAssetsManifestDtoFromJson(json);
}
