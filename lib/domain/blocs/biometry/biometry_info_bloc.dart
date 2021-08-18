import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../logger.dart';
import '../../repositories/biometry_repository.dart';

part 'biometry_info_bloc.freezed.dart';

@injectable
class BiometryInfoBloc extends Bloc<_Event, BiometryInfoState> {
  final BiometryRepository _biometryRepository;
  late final StreamSubscription _streamSubscription;

  BiometryInfoBloc(this._biometryRepository)
      : super(const BiometryInfoState(
          isAvailable: true,
          isEnabled: false,
        )) {
    _streamSubscription = Rx.combineLatest2<bool, bool, Tuple2<bool, bool>>(
      _biometryRepository.biometryAvailabilityStream,
      _biometryRepository.biometryStatusStream,
      (a, b) => Tuple2(a, b),
    ).listen(
      (Tuple2<bool, bool> tuple) => add(
        _LocalEvent.updateBiometryInfo(
          isAvailable: tuple.item1,
          isEnabled: tuple.item2,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _streamSubscription.cancel();
    return super.close();
  }

  @override
  Stream<BiometryInfoState> mapEventToState(_Event event) async* {
    if (event is _LocalEvent) {
      yield* event.when(
        updateBiometryInfo: (
          bool isAvailable,
          bool isEnabled,
        ) async* {
          try {
            yield BiometryInfoState(
              isAvailable: isAvailable,
              isEnabled: isEnabled,
            );
          } on Exception catch (err, st) {
            logger.e(err, err, st);
          }
        },
      );
    }

    if (event is BiometryInfoEvent) {
      yield* event.when(
        setBiometryStatus: (bool isEnabled) async* {
          try {
            final isAuthenticated = await _biometryRepository.authenticate('Authenticate to change user settings');

            if (isAuthenticated) {
              await _biometryRepository.setBiometryStatus(isEnabled: isEnabled);
            }
          } on Exception catch (err, st) {
            logger.e(err, err, st);
          }
        },
        checkBiometryAvailability: () async* {
          try {
            await _biometryRepository.checkBiometryAvailability();
          } on Exception catch (err, st) {
            logger.e(err, err, st);
          }
        },
      );
    }
  }
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.updateBiometryInfo({
    required bool isAvailable,
    required bool isEnabled,
  }) = _UpdateBiometryInfo;
}

@freezed
class BiometryInfoEvent extends _Event with _$BiometryInfoEvent {
  const factory BiometryInfoEvent.setBiometryStatus({required bool isEnabled}) = _SetBiometryStatus;

  const factory BiometryInfoEvent.checkBiometryAvailability() = _CheckBiometryAvailability;
}

@freezed
class BiometryInfoState with _$BiometryInfoState {
  const factory BiometryInfoState({
    required bool isAvailable,
    required bool isEnabled,
  }) = _BiometryInfoState;
}
