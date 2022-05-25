import 'package:freezed_annotation/freezed_annotation.dart';

part 'encode_internal_input_output.freezed.dart';
part 'encode_internal_input_output.g.dart';

@freezed
class EncodeInternalInputOutput with _$EncodeInternalInputOutput {
  const factory EncodeInternalInputOutput({
    required String boc,
  }) = _EncodeInternalInputOutput;

  factory EncodeInternalInputOutput.fromJson(Map<String, dynamic> json) => _$EncodeInternalInputOutputFromJson(json);
}
