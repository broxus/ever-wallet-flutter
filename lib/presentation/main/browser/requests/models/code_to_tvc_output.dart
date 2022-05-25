import 'package:freezed_annotation/freezed_annotation.dart';

part 'code_to_tvc_output.freezed.dart';
part 'code_to_tvc_output.g.dart';

@freezed
class CodeToTvcOutput with _$CodeToTvcOutput {
  const factory CodeToTvcOutput({
    required String tvc,
  }) = _CodeToTvcOutput;

  factory CodeToTvcOutput.fromJson(Map<String, dynamic> json) => _$CodeToTvcOutputFromJson(json);
}
