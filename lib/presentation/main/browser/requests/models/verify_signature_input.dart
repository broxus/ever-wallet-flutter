import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_signature_input.freezed.dart';
part 'verify_signature_input.g.dart';

@freezed
class VerifySignatureInput with _$VerifySignatureInput {
  const factory VerifySignatureInput({
    required String publicKey,
    required String dataHash,
    required String signature,
  }) = _VerifySignatureInput;

  factory VerifySignatureInput.fromJson(Map<String, dynamic> json) => _$VerifySignatureInputFromJson(json);
}
