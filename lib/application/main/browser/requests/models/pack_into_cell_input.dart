import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'pack_into_cell_input.freezed.dart';
part 'pack_into_cell_input.g.dart';

@freezed
class PackIntoCellInput with _$PackIntoCellInput {
  const factory PackIntoCellInput({
    required List<AbiParam> structure,
    required TokensObject data,
  }) = _PackIntoCellInput;

  factory PackIntoCellInput.fromJson(Map<String, dynamic> json) =>
      _$PackIntoCellInputFromJson(json);
}
