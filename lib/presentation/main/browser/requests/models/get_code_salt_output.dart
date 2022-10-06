import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_code_salt_output.freezed.dart';
part 'get_code_salt_output.g.dart';

@freezed
class GetCodeSaltOutput with _$GetCodeSaltOutput {
  const factory GetCodeSaltOutput({
    @JsonKey(includeIfNull: false) String? salt,
  }) = _GetCodeSaltOutput;

  factory GetCodeSaltOutput.fromJson(Map<String, dynamic> json) =>
      _$GetCodeSaltOutputFromJson(json);
}
