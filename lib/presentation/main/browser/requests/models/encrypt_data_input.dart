import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'encrypt_data_input.freezed.dart';
part 'encrypt_data_input.g.dart';

@freezed
class EncryptDataInput with _$EncryptDataInput {
  const factory EncryptDataInput({
    required String publicKey,
    required List<String> recipientPublicKeys,
    required EncryptionAlgorithm algorithm,
    required String data,
  }) = _EncryptDataInput;

  factory EncryptDataInput.fromJson(Map<String, dynamic> json) => _$EncryptDataInputFromJson(json);
}
