import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'decode_input_input.freezed.dart';
part 'decode_input_input.g.dart';

@freezed
class DecodeInputInput with _$DecodeInputInput {
  const factory DecodeInputInput({
    required String body,
    required String abi,
    required MethodName method,
    required bool internal,
  }) = _DecodeInputInput;

  factory DecodeInputInput.fromJson(Map<String, dynamic> json) => _$DecodeInputInputFromJson(json);
}
