import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_changed_event.freezed.dart';
part 'network_changed_event.g.dart';

@freezed
class NetworkChangedEvent with _$NetworkChangedEvent {
  const factory NetworkChangedEvent({
    required String selectedConnection,
  }) = _NetworkChangedEvent;

  factory NetworkChangedEvent.fromJson(Map<String, dynamic> json) => _$NetworkChangedEventFromJson(json);
}
