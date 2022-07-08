import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'send_external_message_output.freezed.dart';
part 'send_external_message_output.g.dart';

@freezed
class SendExternalMessageOutput with _$SendExternalMessageOutput {
  const factory SendExternalMessageOutput({
    required Transaction transaction,
    @JsonKey(includeIfNull: false) TokensObject? output,
  }) = _SendExternalMessageOutput;

  factory SendExternalMessageOutput.fromJson(Map<String, dynamic> json) =>
      _$SendExternalMessageOutputFromJson(json);
}
