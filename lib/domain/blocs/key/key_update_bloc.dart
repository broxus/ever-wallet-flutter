import 'dart:async';

import 'package:bloc/bloc.dart';
import '../../repositories/biometry_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'key_update_bloc.freezed.dart';

@injectable
class KeyUpdateBloc extends Bloc<KeyUpdateEvent, KeyUpdateState> {
  final NekotonService _nekotonService;
  final BiometryRepository _biometryRepository;

  KeyUpdateBloc(
    this._nekotonService,
    this._biometryRepository,
  ) : super(const KeyUpdateState.initial());

  @override
  Stream<KeyUpdateState> mapEventToState(KeyUpdateEvent event) async* {
    yield* event.when(
      changePassword: (
        KeySubject keySubject,
        String oldPassword,
        String newPassword,
      ) async* {
        try {
          late final UpdateKeyInput updateKeyInput;

          if (keySubject.value.isLegacy) {
            updateKeyInput = EncryptedKeyUpdateParams.changePassword(
              publicKey: keySubject.value.publicKey,
              oldPassword: Password.explicit(
                password: oldPassword,
                cacheBehavior: const PasswordCacheBehavior.remove(),
              ),
              newPassword: Password.explicit(
                password: newPassword,
                cacheBehavior: const PasswordCacheBehavior.remove(),
              ),
            );
          } else {
            updateKeyInput = DerivedKeyUpdateParams.changePassword(
              masterKey: keySubject.value.masterKey,
              oldPassword: Password.explicit(
                password: oldPassword,
                cacheBehavior: const PasswordCacheBehavior.remove(),
              ),
              newPassword: Password.explicit(
                password: newPassword,
                cacheBehavior: const PasswordCacheBehavior.remove(),
              ),
            );
          }

          final key = await _nekotonService.updateKey(updateKeyInput);

          await _biometryRepository.setKeyPassword(
            publicKey: key.value.publicKey,
            password: newPassword,
          );

          yield const KeyUpdateState.success();
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield KeyUpdateState.error(err.toString());
        }
      },
      rename: (
        KeySubject keySubject,
        String name,
      ) async* {
        try {
          late final UpdateKeyInput updateKeyInput;

          if (keySubject.value.isLegacy) {
            updateKeyInput = EncryptedKeyUpdateParams.rename(
              publicKey: keySubject.value.publicKey,
              name: name,
            );
          } else {
            updateKeyInput = DerivedKeyUpdateParams.renameKey(
              masterKey: keySubject.value.masterKey,
              publicKey: keySubject.value.publicKey,
              name: name,
            );
          }

          await _nekotonService.updateKey(updateKeyInput);

          yield const KeyUpdateState.success();
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield KeyUpdateState.error(err.toString());
        }
      },
    );
  }
}

@freezed
class KeyUpdateEvent with _$KeyUpdateEvent {
  const factory KeyUpdateEvent.changePassword({
    required KeySubject keySubject,
    required String oldPassword,
    required String newPassword,
  }) = _ChangePassword;

  const factory KeyUpdateEvent.rename({
    required KeySubject keySubject,
    required String name,
  }) = _Rename;
}

@freezed
class KeyUpdateState with _$KeyUpdateState {
  const factory KeyUpdateState.initial() = _Initial;

  const factory KeyUpdateState.success() = _Success;

  const factory KeyUpdateState.error(String info) = _Error;
}
