import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'unpack_from_cell_input.freezed.dart';
part 'unpack_from_cell_input.g.dart';

@freezed
class UnpackFromCellInput with _$UnpackFromCellInput {
  @JsonSerializable(explicitToJson: true)
  const factory UnpackFromCellInput({
    required List<AbiParam> structure,
    required String boc,
    required bool allowPartial,
  }) = _UnpackFromCellInput;

  factory UnpackFromCellInput.fromJson(Map<String, dynamic> json) => _$UnpackFromCellInputFromJson(json);
}
