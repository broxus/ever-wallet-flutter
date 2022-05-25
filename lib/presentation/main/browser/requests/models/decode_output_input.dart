import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'decode_output_input.freezed.dart';
part 'decode_output_input.g.dart';

@freezed
class DecodeOutputInput with _$DecodeOutputInput {
  const factory DecodeOutputInput({
    required String body,
    required String abi,
    required MethodName method,
  }) = _DecodeOutputInput;

  factory DecodeOutputInput.fromJson(Map<String, dynamic> json) => _$DecodeOutputInputFromJson(json);
}
