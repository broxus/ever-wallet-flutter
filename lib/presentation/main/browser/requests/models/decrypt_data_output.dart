import 'package:freezed_annotation/freezed_annotation.dart';

part 'decrypt_data_output.freezed.dart';
part 'decrypt_data_output.g.dart';

@freezed
class DecryptDataOutput with _$DecryptDataOutput {
  const factory DecryptDataOutput({
    required String data,
  }) = _DecryptDataOutput;

  factory DecryptDataOutput.fromJson(Map<String, dynamic> json) => _$DecryptDataOutputFromJson(json);
}
