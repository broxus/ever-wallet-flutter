import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'send_message_input.freezed.dart';
part 'send_message_input.g.dart';

@freezed
class SendMessageInput with _$SendMessageInput {
  @JsonSerializable(explicitToJson: true)
  const factory SendMessageInput({
    required String sender,
    required String recipient,
    required String amount,
    required bool bounce,
    FunctionCall? payload,
  }) = _SendMessageInput;

  factory SendMessageInput.fromJson(Map<String, dynamic> json) => _$SendMessageInputFromJson(json);
}
