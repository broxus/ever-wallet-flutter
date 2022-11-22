import 'package:ever_wallet/application/main/browser/requests/models/delayed_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_message_delayed_output.freezed.dart';
part 'send_message_delayed_output.g.dart';

@freezed
class SendMessageDelayedOutput with _$SendMessageDelayedOutput {
  @JsonSerializable(explicitToJson: true)
  const factory SendMessageDelayedOutput({
    required DelayedMessage message,
  }) = _SendMessageDelayedOutput;

  factory SendMessageDelayedOutput.fromJson(Map<String, dynamic> json) =>
      _$SendMessageDelayedOutputFromJson(json);
}
