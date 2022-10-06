import 'package:freezed_annotation/freezed_annotation.dart';

part 'delayed_message.freezed.dart';
part 'delayed_message.g.dart';

@freezed
class DelayedMessage with _$DelayedMessage {
  const factory DelayedMessage({
    required String hash,
    required String account,
    required int expireAt,
  }) = _DelayedMessage;

  factory DelayedMessage.fromJson(Map<String, dynamic> json) => _$DelayedMessageFromJson(json);
}
