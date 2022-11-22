import 'package:freezed_annotation/freezed_annotation.dart';

part 'set_code_salt_input.freezed.dart';
part 'set_code_salt_input.g.dart';

@freezed
class SetCodeSaltInput with _$SetCodeSaltInput {
  const factory SetCodeSaltInput({
    required String code,
    required String salt,
  }) = _SetCodeSaltInput;

  factory SetCodeSaltInput.fromJson(Map<String, dynamic> json) => _$SetCodeSaltInputFromJson(json);
}
