import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../logger.dart';
import '../repositories/biometry_repository.dart';
import '../repositories/connected_sites_repository.dart';
import '../repositories/ton_assets_repository.dart';
import '../repositories/user_preferences_repository.dart';
import '../services/nekoton_service.dart';
import 'common/notification_bloc.dart';

part 'application_flow_bloc.freezed.dart';

@injectable
class ApplicationFlowBloc extends Bloc<_Event, ApplicationFlowState> {
  final NekotonService _nekotonService;
  final BiometryRepository _biometryRepository;
  final ConnectedSitesRepository _connectedSitesRepository;
  final TonAssetsRepository _tonAssetsRepository;
  final UserPreferencesRepository _userPreferencesRepository;
  late final StreamSubscription _keysPresenceSubscription;
  final notificationBloc = NotificationBloc();

  ApplicationFlowBloc(
    this._nekotonService,
    this._biometryRepository,
    this._connectedSitesRepository,
    this._tonAssetsRepository,
    this._userPreferencesRepository,
  ) : super(const ApplicationFlowState.loading()) {
    _keysPresenceSubscription = _nekotonService.keysPresenceStream
        .listen((bool hasKeys) => add(_LocalEvent.updateApplicationState(hasKeys: hasKeys)));
  }

  @override
  Future<void> close() {
    _keysPresenceSubscription.cancel();
    return super.close();
  }

  @override
  Stream<ApplicationFlowState> mapEventToState(_Event event) async* {
    if (event is _LocalEvent) {
      yield* event.when(
        updateApplicationState: (bool hasKeys) async* {
          try {
            if (hasKeys) {
              yield const ApplicationFlowState.home();
            } else {
              yield const ApplicationFlowState.welcome();
            }
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            notificationBloc.add(NotificationEvent.showError(err.toString()));
          }
        },
      );
    }

    if (event is ApplicationFlowEvent) {
      yield* event.when(
        logOut: () async* {
          try {
            yield const ApplicationFlowState.loading();

            await _nekotonService.clearAccountsStorage();
            await _nekotonService.clearKeystore();
            await _biometryRepository.clear();
            await _connectedSitesRepository.clear();
            await _tonAssetsRepository.clear();
            await _userPreferencesRepository.clear();
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            notificationBloc.add(NotificationEvent.showError(err.toString()));
          }
        },
      );
    }
  }
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.updateApplicationState({required bool hasKeys}) = _UpdateApplicationState;
}

@freezed
class ApplicationFlowEvent extends _Event with _$ApplicationFlowEvent {
  const factory ApplicationFlowEvent.logOut() = _LogOut;
}

@freezed
class ApplicationFlowState with _$ApplicationFlowState {
  const factory ApplicationFlowState.loading() = _Loading;

  const factory ApplicationFlowState.welcome() = _Welcome;

  const factory ApplicationFlowState.home() = _Home;
}
