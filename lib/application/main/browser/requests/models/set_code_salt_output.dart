import 'package:freezed_annotation/freezed_annotation.dart';

part 'set_code_salt_output.freezed.dart';
part 'set_code_salt_output.g.dart';

@freezed
class SetCodeSaltOutput with _$SetCodeSaltOutput {
  const factory SetCodeSaltOutput({
    required String code,
  }) = _SetCodeSaltOutput;

  factory SetCodeSaltOutput.fromJson(Map<String, dynamic> json) =>
      _$SetCodeSaltOutputFromJson(json);
}
