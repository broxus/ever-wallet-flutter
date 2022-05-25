import 'package:freezed_annotation/freezed_annotation.dart';

part 'extract_public_key_output.freezed.dart';
part 'extract_public_key_output.g.dart';

@freezed
class ExtractPublicKeyOutput with _$ExtractPublicKeyOutput {
  const factory ExtractPublicKeyOutput({
    required String publicKey,
  }) = _ExtractPublicKeyOutput;

  factory ExtractPublicKeyOutput.fromJson(Map<String, dynamic> json) => _$ExtractPublicKeyOutputFromJson(json);
}
