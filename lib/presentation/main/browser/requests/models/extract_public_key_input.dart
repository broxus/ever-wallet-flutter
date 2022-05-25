import 'package:freezed_annotation/freezed_annotation.dart';

part 'extract_public_key_input.freezed.dart';
part 'extract_public_key_input.g.dart';

@freezed
class ExtractPublicKeyInput with _$ExtractPublicKeyInput {
  const factory ExtractPublicKeyInput({
    required String boc,
  }) = _ExtractPublicKeyInput;

  factory ExtractPublicKeyInput.fromJson(Map<String, dynamic> json) => _$ExtractPublicKeyInputFromJson(json);
}
