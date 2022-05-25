import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'encrypt_data_output.freezed.dart';
part 'encrypt_data_output.g.dart';

@freezed
class EncryptDataOutput with _$EncryptDataOutput {
  @JsonSerializable(explicitToJson: true)
  const factory EncryptDataOutput({
    required List<EncryptedData> encryptedData,
  }) = _EncryptDataOutput;

  factory EncryptDataOutput.fromJson(Map<String, dynamic> json) => _$EncryptDataOutputFromJson(json);
}
