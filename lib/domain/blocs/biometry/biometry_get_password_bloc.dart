import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../data/repositories/biometry_repository.dart';
import '../../../logger.dart';

part 'biometry_get_password_bloc.freezed.dart';

@injectable
class BiometryGetPasswordBloc extends Bloc<BiometryGetPasswordEvent, BiometryGetPasswordState> {
  final BiometryRepository _biometryRepository;

  BiometryGetPasswordBloc(this._biometryRepository) : super(const BiometryGetPasswordState.initial());

  @override
  Stream<BiometryGetPasswordState> mapEventToState(BiometryGetPasswordEvent event) async* {
    try {
      if (event is _Get) {
        final password = _biometryRepository.getKeyPassword(event.publicKey);

        if (password != null) {
          final isAuthenticated = await _biometryRepository.authenticate(event.localizedReason);

          if (isAuthenticated) {
            yield BiometryGetPasswordState.success(password);
          } else {
            yield const BiometryGetPasswordState.success();
          }
        } else {
          yield const BiometryGetPasswordState.success();
        }
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield BiometryGetPasswordState.error(err);
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

@freezed
class BiometryGetPasswordState with _$BiometryGetPasswordState {
  const factory BiometryGetPasswordState.initial() = _Initial;

  const factory BiometryGetPasswordState.success([String? password]) = _Success;

  const factory BiometryGetPasswordState.error(Exception exception) = _Error;

  const BiometryGetPasswordState._();

  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => 0;
}
