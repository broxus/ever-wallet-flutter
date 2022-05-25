import 'package:freezed_annotation/freezed_annotation.dart';

part 'pack_into_cell_output.freezed.dart';
part 'pack_into_cell_output.g.dart';

@freezed
class PackIntoCellOutput with _$PackIntoCellOutput {
  const factory PackIntoCellOutput({
    required String boc,
  }) = _PackIntoCellOutput;

  factory PackIntoCellOutput.fromJson(Map<String, dynamic> json) => _$PackIntoCellOutputFromJson(json);
}
