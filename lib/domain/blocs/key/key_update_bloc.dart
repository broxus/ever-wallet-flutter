import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../repositories/biometry_repository.dart';
import '../../services/nekoton_service.dart';

part 'key_update_bloc.freezed.dart';

@injectable
class KeyUpdateBloc extends Bloc<KeyUpdateEvent, KeyUpdateState> {
  final NekotonService _nekotonService;
  final BiometryRepository _biometryRepository;
  final _errorsSubject = PublishSubject<String>();

  KeyUpdateBloc(
    this._nekotonService,
    this._biometryRepository,
  ) : super(const KeyUpdateState.initial());

  @override
  Future<void> close() {
    _errorsSubject.close();
    return super.close();
  }

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

        yield const KeyUpdateState.success();
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

        yield const KeyUpdateState.success();
      }
    } catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err.toString());
    }
  }

  Stream<String> get errorsStream => _errorsSubject.stream;
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

@freezed
class KeyUpdateState with _$KeyUpdateState {
  const factory KeyUpdateState.initial() = _Initial;

  const factory KeyUpdateState.success() = _Success;
}
