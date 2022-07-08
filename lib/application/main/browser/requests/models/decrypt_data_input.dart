import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'decrypt_data_input.freezed.dart';
part 'decrypt_data_input.g.dart';

@freezed
class DecryptDataInput with _$DecryptDataInput {
  const factory DecryptDataInput({
    required EncryptedData encryptedData,
  }) = _DecryptDataInput;

  factory DecryptDataInput.fromJson(Map<String, dynamic> json) => _$DecryptDataInputFromJson(json);
}
