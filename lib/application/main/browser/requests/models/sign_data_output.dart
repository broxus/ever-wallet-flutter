import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'sign_data_output.freezed.dart';
part 'sign_data_output.g.dart';

@freezed
class SignDataOutput with _$SignDataOutput {
  const factory SignDataOutput({
    required String dataHash,
    required String signature,
    required String signatureHex,
    required SignatureParts signatureParts,
  }) = _SignDataOutput;

  factory SignDataOutput.fromJson(Map<String, dynamic> json) => _$SignDataOutputFromJson(json);
}
