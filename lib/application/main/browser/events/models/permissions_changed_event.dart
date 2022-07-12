import 'package:ever_wallet/data/models/permissions.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'permissions_changed_event.freezed.dart';
part 'permissions_changed_event.g.dart';

@freezed
class PermissionsChangedEvent with _$PermissionsChangedEvent {
  const factory PermissionsChangedEvent({
    required Permissions permissions,
  }) = _PermissionsChangedEvent;

  factory PermissionsChangedEvent.fromJson(Map<String, dynamic> json) =>
      _$PermissionsChangedEventFromJson(json);
}
