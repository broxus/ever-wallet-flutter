import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_data_raw_input.freezed.dart';
part 'sign_data_raw_input.g.dart';

@freezed
class SignDataRawInput with _$SignDataRawInput {
  const factory SignDataRawInput({
    required String publicKey,
    required String data,
  }) = _SignDataRawInput;

  factory SignDataRawInput.fromJson(Map<String, dynamic> json) => _$SignDataRawInputFromJson(json);
}
