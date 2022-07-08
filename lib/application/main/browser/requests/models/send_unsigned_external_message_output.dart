import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'send_unsigned_external_message_output.freezed.dart';
part 'send_unsigned_external_message_output.g.dart';

@freezed
class SendUnsignedExternalMessageOutput with _$SendUnsignedExternalMessageOutput {
  const factory SendUnsignedExternalMessageOutput({
    required Transaction transaction,
    @JsonKey(includeIfNull: false) TokensObject? output,
  }) = _SendUnsignedExternalMessageOutput;

  factory SendUnsignedExternalMessageOutput.fromJson(Map<String, dynamic> json) =>
      _$SendUnsignedExternalMessageOutputFromJson(json);
}
