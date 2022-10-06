import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'message_status_updated_event.freezed.dart';
part 'message_status_updated_event.g.dart';

@freezed
class MessageStatusUpdatedEvent with _$MessageStatusUpdatedEvent {
  @JsonSerializable(explicitToJson: true)
  const factory MessageStatusUpdatedEvent({
    required String address,
    required String hash,
    required Transaction? transaction,
  }) = _MessageStatusUpdatedEvent;

  factory MessageStatusUpdatedEvent.fromJson(Map<String, dynamic> json) =>
      _$MessageStatusUpdatedEventFromJson(json);
}
