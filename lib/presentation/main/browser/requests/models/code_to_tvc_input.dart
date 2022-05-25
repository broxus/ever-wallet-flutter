import 'package:freezed_annotation/freezed_annotation.dart';

part 'code_to_tvc_input.freezed.dart';
part 'code_to_tvc_input.g.dart';

@freezed
class CodeToTvcInput with _$CodeToTvcInput {
  const factory CodeToTvcInput({
    required String code,
  }) = _CodeToTvcInput;

  factory CodeToTvcInput.fromJson(Map<String, dynamic> json) => _$CodeToTvcInputFromJson(json);
}
