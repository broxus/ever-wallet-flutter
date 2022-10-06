import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'send_message_delayed_input.freezed.dart';
part 'send_message_delayed_input.g.dart';

@freezed
class SendMessageDelayedInput with _$SendMessageDelayedInput {
  @JsonSerializable(explicitToJson: true)
  const factory SendMessageDelayedInput({
    required String sender,
    required String recipient,
    required String amount,
    required bool bounce,
    FunctionCall? payload,
  }) = _SendMessageDelayedInput;

  factory SendMessageDelayedInput.fromJson(Map<String, dynamic> json) =>
      _$SendMessageDelayedInputFromJson(json);
}
