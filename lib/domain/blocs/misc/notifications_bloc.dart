import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../logger.dart';
import '../../models/app_notification.dart';

part 'notifications_bloc.freezed.dart';

@injectable
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc() : super(const NotificationsState.initial()) {
    add(const NotificationsEvent.updateNotifications());
  }

  @override
  Stream<NotificationsState> mapEventToState(NotificationsEvent event) async* {
    yield* event.when(
      updateNotifications: () async* {
        try {
          final notifications = <DateTime, List<AppNotification>>{};
          yield NotificationsState.ready({...notifications});
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield NotificationsState.error(err.toString());
        }
      },
    );
  }
}

@freezed
class NotificationsEvent with _$NotificationsEvent {
  const factory NotificationsEvent.updateNotifications() = _UpdateNotifications;
}

@freezed
class NotificationsState with _$NotificationsState {
  const factory NotificationsState.initial() = _Initial;

  const factory NotificationsState.ready(Map<DateTime, List<AppNotification>> notifications) = _Ready;

  const factory NotificationsState.error(String info) = _Error;
}
