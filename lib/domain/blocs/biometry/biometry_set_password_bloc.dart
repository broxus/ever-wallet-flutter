import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../logger.dart';
import '../../repositories/biometry_repository.dart';

part 'biometry_set_password_bloc.freezed.dart';

@injectable
class BiometrySetPasswordBloc extends Bloc<BiometrySetPasswordEvent, BiometrySetPasswordState> {
  final BiometryRepository _biometryRepository;

  BiometrySetPasswordBloc(this._biometryRepository) : super(BiometrySetPasswordStateInitial());

  @override
  Stream<BiometrySetPasswordState> mapEventToState(BiometrySetPasswordEvent event) async* {
    try {
      if (event is _Set) {
        await _biometryRepository.setKeyPassword(
          publicKey: event.publicKey,
          password: event.password,
        );

        yield BiometrySetPasswordStateSuccess();
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield BiometrySetPasswordStateError(err);
    }
  }
}

@freezed
class BiometrySetPasswordEvent with _$BiometrySetPasswordEvent {
  const factory BiometrySetPasswordEvent.set({
    required String publicKey,
    required String password,
  }) = _Set;
}

abstract class BiometrySetPasswordState {}

class BiometrySetPasswordStateInitial extends BiometrySetPasswordState {}

class BiometrySetPasswordStateSuccess extends BiometrySetPasswordState {}

class BiometrySetPasswordStateError extends BiometrySetPasswordState {
  final Exception exception;

  BiometrySetPasswordStateError(this.exception);
}
