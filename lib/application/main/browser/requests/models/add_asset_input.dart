import 'package:ever_wallet/data/models/asset_type.dart';
import 'package:ever_wallet/data/models/asset_type_params.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_asset_input.freezed.dart';
part 'add_asset_input.g.dart';

@freezed
class AddAssetInput with _$AddAssetInput {
  const factory AddAssetInput({
    required String account,
    required AssetType type,
    required AssetTypeParams params,
  }) = _AddAssetInput;

  factory AddAssetInput.fromJson(Map<String, dynamic> json) => _$AddAssetInputFromJson(json);
}
