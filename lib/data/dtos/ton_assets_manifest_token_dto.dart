import 'package:freezed_annotation/freezed_annotation.dart';

part 'ton_assets_manifest_token_dto.freezed.dart';
part 'ton_assets_manifest_token_dto.g.dart';

@freezed
class TonAssetsManifestTokenDto with _$TonAssetsManifestTokenDto {
  const factory TonAssetsManifestTokenDto({
    required String name,
    int? chainId,
    required String symbol,
    required int decimals,
    required String address,
    String? logoURI,
    required int version,
  }) = _TonAssetsManifestTokenDto;

  factory TonAssetsManifestTokenDto.fromJson(Map<String, dynamic> json) => _$TonAssetsManifestTokenDtoFromJson(json);
}
