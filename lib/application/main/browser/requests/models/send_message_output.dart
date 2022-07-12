import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'send_message_output.freezed.dart';
part 'send_message_output.g.dart';

@freezed
class SendMessageOutput with _$SendMessageOutput {
  const factory SendMessageOutput({
    required Transaction transaction,
  }) = _SendMessageOutput;

  factory SendMessageOutput.fromJson(Map<String, dynamic> json) =>
      _$SendMessageOutputFromJson(json);
}
