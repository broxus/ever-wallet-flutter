import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../data/repositories/biometry_repository.dart';
import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';

part 'key_update_bloc.freezed.dart';

@injectable
class KeyUpdateBloc extends Bloc<KeyUpdateEvent, KeyUpdateState> {
  final NekotonService _nekotonService;
  final BiometryRepository _biometryRepository;

  KeyUpdateBloc(
    this._nekotonService,
    this._biometryRepository,
  ) : super(KeyUpdateStateInitial());

  @override
  Stream<KeyUpdateState> mapEventToState(KeyUpdateEvent event) async* {
    try {
      if (event is _ChangePassword) {
        final key = _nekotonService.keys.firstWhereOrNull((e) => e.publicKey == event.publicKey);

        if (key == null) {
          throw KeyNotFoundException();
        }

        late final UpdateKeyInput updateKeyInput;

        if (key.isLegacy) {
          updateKeyInput = EncryptedKeyUpdateParams.changePassword(
            publicKey: key.publicKey,
            oldPassword: Password.explicit(
              password: event.oldPassword,
              cacheBehavior: const PasswordCacheBehavior.remove(),
            ),
            newPassword: Password.explicit(
              password: event.newPassword,
              cacheBehavior: const PasswordCacheBehavior.remove(),
            ),
          );
        } else {
          updateKeyInput = DerivedKeyUpdateParams.changePassword(
            masterKey: key.masterKey,
            oldPassword: Password.explicit(
              password: event.oldPassword,
              cacheBehavior: const PasswordCacheBehavior.remove(),
            ),
            newPassword: Password.explicit(
              password: event.newPassword,
              cacheBehavior: const PasswordCacheBehavior.remove(),
            ),
          );
        }

        final updatedKey = await _nekotonService.updateKey(updateKeyInput);

        await _biometryRepository.setKeyPassword(
          publicKey: updatedKey.publicKey,
          password: event.newPassword,
        );

        yield KeyUpdateStateSuccess();
      } else if (event is _Rename) {
        final key = _nekotonService.keys.firstWhereOrNull((e) => e.publicKey == event.publicKey);

        if (key == null) {
          throw KeyNotFoundException();
        }

        late final UpdateKeyInput updateKeyInput;

        if (key.isLegacy) {
          updateKeyInput = EncryptedKeyUpdateParams.rename(
            publicKey: key.publicKey,
            name: event.name,
          );
        } else {
          updateKeyInput = DerivedKeyUpdateParams.renameKey(
            masterKey: key.masterKey,
            publicKey: key.publicKey,
            name: event.name,
          );
        }

        await _nekotonService.updateKey(updateKeyInput);

        yield KeyUpdateStateSuccess();
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield KeyUpdateStateError(err);
    }
  }
}

@freezed
class KeyUpdateEvent with _$KeyUpdateEvent {
  const factory KeyUpdateEvent.changePassword({
    required String publicKey,
    required String oldPassword,
    required String newPassword,
  }) = _ChangePassword;

  const factory KeyUpdateEvent.rename({
    required String publicKey,
    required String name,
  }) = _Rename;
}

abstract class KeyUpdateState {}

class KeyUpdateStateInitial extends KeyUpdateState {}

class KeyUpdateStateSuccess extends KeyUpdateState {}

class KeyUpdateStateError extends KeyUpdateState {
  final Exception exception;

  KeyUpdateStateError(this.exception);
}
