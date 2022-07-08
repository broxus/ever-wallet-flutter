import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_data_input.freezed.dart';
part 'sign_data_input.g.dart';

@freezed
class SignDataInput with _$SignDataInput {
  const factory SignDataInput({
    required String publicKey,
    required String data,
  }) = _SignDataInput;

  factory SignDataInput.fromJson(Map<String, dynamic> json) => _$SignDataInputFromJson(json);
}
