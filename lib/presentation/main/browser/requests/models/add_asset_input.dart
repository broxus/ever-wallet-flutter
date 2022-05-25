import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../data/models/asset_type.dart';
import '../../../../../data/models/asset_type_params.dart';

part 'add_asset_input.freezed.dart';
part 'add_asset_input.g.dart';

@freezed
class AddAssetInput with _$AddAssetInput {
  @JsonSerializable(explicitToJson: true)
  const factory AddAssetInput({
    required String account,
    required AssetType type,
    required AssetTypeParams params,
  }) = _AddAssetInput;

  factory AddAssetInput.fromJson(Map<String, dynamic> json) => _$AddAssetInputFromJson(json);
}
