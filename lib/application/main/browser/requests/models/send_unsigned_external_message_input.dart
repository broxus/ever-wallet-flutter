import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'send_unsigned_external_message_input.freezed.dart';
part 'send_unsigned_external_message_input.g.dart';

@freezed
class SendUnsignedExternalMessageInput with _$SendUnsignedExternalMessageInput {
  const factory SendUnsignedExternalMessageInput({
    required String recipient,
    String? stateInit,
    required FunctionCall payload,
    bool? local,
  }) = _SendUnsignedExternalMessageInput;

  factory SendUnsignedExternalMessageInput.fromJson(Map<String, dynamic> json) =>
      _$SendUnsignedExternalMessageInputFromJson(json);
}
