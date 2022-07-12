import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_asset_output.freezed.dart';
part 'add_asset_output.g.dart';

@freezed
class AddAssetOutput with _$AddAssetOutput {
  const factory AddAssetOutput({
    required bool newAsset,
  }) = _AddAssetOutput;

  factory AddAssetOutput.fromJson(Map<String, dynamic> json) => _$AddAssetOutputFromJson(json);
}
