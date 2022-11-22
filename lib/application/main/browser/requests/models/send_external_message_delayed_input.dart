import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'send_external_message_delayed_input.freezed.dart';
part 'send_external_message_delayed_input.g.dart';

@freezed
class SendExternalMessageDelayedInput with _$SendExternalMessageDelayedInput {
  @JsonSerializable(explicitToJson: true)
  const factory SendExternalMessageDelayedInput({
    required String publicKey,
    required String recipient,
    String? stateInit,
    required FunctionCall payload,
  }) = _SendExternalMessageDelayedInput;

  factory SendExternalMessageDelayedInput.fromJson(Map<String, dynamic> json) =>
      _$SendExternalMessageDelayedInputFromJson(json);
}
