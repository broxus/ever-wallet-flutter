import 'package:freezed_annotation/freezed_annotation.dart';

part 'ton_assets_manifest_version_dto.freezed.dart';
part 'ton_assets_manifest_version_dto.g.dart';

@freezed
class TonAssetsManifestVersionDto with _$TonAssetsManifestVersionDto {
  const factory TonAssetsManifestVersionDto({
    required int major,
    required int minor,
    required int patch,
  }) = _TonAssetsManifestVersionDto;

  factory TonAssetsManifestVersionDto.fromJson(Map<String, dynamic> json) =>
      _$TonAssetsManifestVersionDtoFromJson(json);
}
