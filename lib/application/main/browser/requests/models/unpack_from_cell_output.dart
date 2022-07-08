import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'unpack_from_cell_output.freezed.dart';
part 'unpack_from_cell_output.g.dart';

@freezed
class UnpackFromCellOutput with _$UnpackFromCellOutput {
  const factory UnpackFromCellOutput({
    required TokensObject data,
  }) = _UnpackFromCellOutput;

  factory UnpackFromCellOutput.fromJson(Map<String, dynamic> json) =>
      _$UnpackFromCellOutputFromJson(json);
}
