import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_signature_output.freezed.dart';
part 'verify_signature_output.g.dart';

@freezed
class VerifySignatureOutput with _$VerifySignatureOutput {
  const factory VerifySignatureOutput({
    required bool isValid,
  }) = _VerifySignatureOutput;

  factory VerifySignatureOutput.fromJson(Map<String, dynamic> json) =>
      _$VerifySignatureOutputFromJson(json);
}
