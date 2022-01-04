import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../data/repositories/biometry_repository.dart';
import '../../../logger.dart';

part 'biometry_info_bloc.freezed.dart';

@injectable
class BiometryInfoBloc extends Bloc<_Event, BiometryInfoState> {
  final BiometryRepository _biometryRepository;
  final _errorsSubject = PublishSubject<Exception>();
  late final StreamSubscription _streamSubscription;

  BiometryInfoBloc(this._biometryRepository) : super(const BiometryInfoState()) {
    _streamSubscription = Rx.combineLatest2<bool, bool, Tuple2<bool, bool>>(
      _biometryRepository.biometryAvailabilityStream,
      _biometryRepository.biometryStatusStream,
      (a, b) => Tuple2(a, b),
    ).listen(
      (Tuple2<bool, bool> tuple) => add(
        _LocalEvent.update(
          isAvailable: tuple.item1,
          isEnabled: tuple.item2,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription.cancel();
    return super.close();
  }

  @override
  Stream<BiometryInfoState> mapEventToState(_Event event) async* {
    try {
      if (event is _SetStatus) {
        final isAuthenticated = await _biometryRepository.authenticate(event.localizedReason);

        if (isAuthenticated) {
          await _biometryRepository.setBiometryStatus(event.isEnabled);
        }
      } else if (event is _CheckAvailability) {
        await _biometryRepository.checkBiometryAvailability();
      } else if (event is _Update) {
        yield BiometryInfoState(
          isAvailable: event.isAvailable ?? state.isAvailable,
          isEnabled: event.isEnabled ?? state.isEnabled,
        );
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err);
    }
  }

  Stream<Exception> get errorsStream => _errorsSubject.stream;
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.update({
    bool? isAvailable,
    bool? isEnabled,
  }) = _Update;
}

@freezed
class BiometryInfoEvent extends _Event with _$BiometryInfoEvent {
  const factory BiometryInfoEvent.setStatus({
    required String localizedReason,
    required bool isEnabled,
  }) = _SetStatus;

  const factory BiometryInfoEvent.checkAvailability() = _CheckAvailability;
}

@freezed
class BiometryInfoState with _$BiometryInfoState {
  const factory BiometryInfoState({
    @Default(false) bool isAvailable,
    @Default(false) bool isEnabled,
  }) = _BiometryInfoState;
}
