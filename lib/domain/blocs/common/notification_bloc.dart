import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'notification_bloc.freezed.dart';

@injectable
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(const NotificationState.empty());

  @override
  Stream<NotificationState> mapEventToState(NotificationEvent event) async* {
    yield* event.when(
      showError: (String info) async* {
        yield NotificationState.error(info);
      },
    );
  }
}

@freezed
class NotificationEvent with _$NotificationEvent {
  const factory NotificationEvent.showError(String info) = _ShowError;
}

@freezed
class NotificationState with _$NotificationState {
  const factory NotificationState.empty() = _Empty;

  const factory NotificationState.error(String info) = _Error;
}
