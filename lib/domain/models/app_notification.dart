import 'package:freezed_annotation/freezed_annotation.dart';

import 'app_notification_action.dart';

part 'app_notification.freezed.dart';

@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String text,
    required DateTime time,
    required AppNotificationAction action,
  }) = _AppNotification;
}
