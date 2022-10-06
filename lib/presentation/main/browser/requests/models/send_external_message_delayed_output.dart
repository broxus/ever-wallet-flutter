import 'package:freezed_annotation/freezed_annotation.dart';

import 'delayed_message.dart';

part 'send_external_message_delayed_output.freezed.dart';
part 'send_external_message_delayed_output.g.dart';

@freezed
class SendExternalMessageDelayedOutput with _$SendExternalMessageDelayedOutput {
  @JsonSerializable(explicitToJson: true)
  const factory SendExternalMessageDelayedOutput({
    required DelayedMessage message,
  }) = _SendExternalMessageDelayedOutput;

  factory SendExternalMessageDelayedOutput.fromJson(Map<String, dynamic> json) =>
      _$SendExternalMessageDelayedOutputFromJson(json);
}
