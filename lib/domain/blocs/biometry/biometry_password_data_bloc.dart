import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../logger.dart';
import '../../repositories/biometry_repository.dart';

part 'biometry_password_data_bloc.freezed.dart';

@injectable
class BiometryPasswordDataBloc extends Bloc<BiometryPasswordDataEvent, BiometryPasswordDataState> {
  final BiometryRepository _biometryRepository;

  BiometryPasswordDataBloc(this._biometryRepository) : super(const BiometryPasswordDataState.initial());

  @override
  Stream<BiometryPasswordDataState> mapEventToState(BiometryPasswordDataEvent event) async* {
    if (event is BiometryPasswordDataEvent) {
      yield* event.when(
        getKeyPassword: (String publicKey) async* {
          try {
            final isAvailable = _biometryRepository.biometryAvailability;
            final isEnabled = _biometryRepository.biometryStatus;

            if (!isAvailable || !isEnabled) {
              throw UnimplementedError();
            }

            final password = await _biometryRepository.getKeyPassword(publicKey);

            if (password != null) {
              final isAuthenticated =
                  await _biometryRepository.authenticate('Please authenticate to interact with wallet');

              if (isAuthenticated) {
                yield BiometryPasswordDataState.ready(password);
              }
            } else {
              yield const BiometryPasswordDataState.ready();
            }
          } on Exception catch (err, st) {
            logger.e(err, err, st);
          }
        },
        setKeyPassword: (
          String publicKey,
          String password,
        ) async* {
          try {
            final isAvailable = _biometryRepository.biometryAvailability;
            final isEnabled = _biometryRepository.biometryStatus;

            if (isAvailable && isEnabled) {
              await _biometryRepository.setKeyPassword(
                publicKey: publicKey,
                password: password,
              );
            }
          } on Exception catch (err, st) {
            logger.e(err, err, st);
          }
        },
      );
    }
  }
}

@freezed
class BiometryPasswordDataEvent with _$BiometryPasswordDataEvent {
  const factory BiometryPasswordDataEvent.getKeyPassword(String publicKey) = _GetKeyPassword;

  const factory BiometryPasswordDataEvent.setKeyPassword({
    required String publicKey,
    required String password,
  }) = _SetKeyPassword;
}

@freezed
class BiometryPasswordDataState with _$BiometryPasswordDataState {
  const factory BiometryPasswordDataState.initial() = _Initial;

  const factory BiometryPasswordDataState.ready([String? password]) = _Ready;
}
