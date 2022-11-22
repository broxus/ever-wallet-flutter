import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_code_salt_input.freezed.dart';
part 'get_code_salt_input.g.dart';

@freezed
class GetCodeSaltInput with _$GetCodeSaltInput {
  const factory GetCodeSaltInput({
    required String code,
  }) = _GetCodeSaltInput;

  factory GetCodeSaltInput.fromJson(Map<String, dynamic> json) => _$GetCodeSaltInputFromJson(json);
}
