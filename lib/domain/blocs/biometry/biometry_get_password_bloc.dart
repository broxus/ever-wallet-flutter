import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../logger.dart';
import '../../repositories/biometry_repository.dart';

part 'biometry_get_password_bloc.freezed.dart';

@injectable
class BiometryGetPasswordBloc extends Bloc<BiometryGetPasswordEvent, BiometryGetPasswordState> {
  final BiometryRepository _biometryRepository;

  BiometryGetPasswordBloc(this._biometryRepository) : super(BiometryGetPasswordStateInitial());

  @override
  Stream<BiometryGetPasswordState> mapEventToState(BiometryGetPasswordEvent event) async* {
    try {
      if (event is _Get) {
        final password = _biometryRepository.getKeyPassword(event.publicKey);

        if (password != null) {
          final isAuthenticated = await _biometryRepository.authenticate(event.localizedReason);

          if (isAuthenticated) {
            yield BiometryGetPasswordStateSuccess(password);
          } else {
            yield BiometryGetPasswordStateSuccess();
          }
        } else {
          yield BiometryGetPasswordStateSuccess();
        }
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield BiometryGetPasswordStateError(err);
    }
  }
}

@freezed
class BiometryGetPasswordEvent with _$BiometryGetPasswordEvent {
  const factory BiometryGetPasswordEvent.get({
    required String localizedReason,
    required String publicKey,
  }) = _Get;
}

abstract class BiometryGetPasswordState {}

class BiometryGetPasswordStateInitial extends BiometryGetPasswordState {}

class BiometryGetPasswordStateSuccess extends BiometryGetPasswordState {
  final String? password;

  BiometryGetPasswordStateSuccess([this.password]);
}

class BiometryGetPasswordStateError extends BiometryGetPasswordState {
  final Exception exception;

  BiometryGetPasswordStateError(this.exception);
}
