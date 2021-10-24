import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../repositories/biometry_repository.dart';

part 'biometry_password_data_bloc.freezed.dart';

@injectable
class BiometryPasswordDataBloc extends Bloc<BiometryPasswordDataEvent, BiometryPasswordDataState> {
  final BiometryRepository _biometryRepository;
  final _errorsSubject = PublishSubject<String>();

  BiometryPasswordDataBloc(this._biometryRepository) : super(const BiometryPasswordDataState.initial());

  @override
  Future<void> close() {
    _errorsSubject.close();
    return super.close();
  }

  @override
  Stream<BiometryPasswordDataState> mapEventToState(BiometryPasswordDataEvent event) async* {
    try {
      if (event is _Get) {
        final password = await _biometryRepository.get(event.publicKey);

        if (password != null) {
          final isAuthenticated = await _biometryRepository.authenticate('Please authenticate to interact with wallet');

          if (isAuthenticated) {
            yield BiometryPasswordDataState.ready(password);
          } else {
            yield const BiometryPasswordDataState.ready();
          }
        } else {
          yield const BiometryPasswordDataState.ready();
        }
      } else if (event is _Set) {
        await _biometryRepository.setKeyPassword(
          publicKey: event.publicKey,
          password: event.password,
        );
      }
    } catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err.toString());
    }
  }

  Stream<String> get errorsStream => _errorsSubject.stream;
}

@freezed
class BiometryPasswordDataEvent with _$BiometryPasswordDataEvent {
  const factory BiometryPasswordDataEvent.get(String publicKey) = _Get;

  const factory BiometryPasswordDataEvent.set({
    required String publicKey,
    required String password,
  }) = _Set;
}

@freezed
class BiometryPasswordDataState with _$BiometryPasswordDataState {
  const factory BiometryPasswordDataState.initial() = _Initial;

  const factory BiometryPasswordDataState.ready([String? password]) = _Ready;
}
