import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../data/repositories/biometry_repository.dart';
import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';

part 'key_creation_bloc.freezed.dart';

@injectable
class KeyCreationBloc extends Bloc<KeyCreationEvent, KeyCreationState> {
  final NekotonService _nekotonService;
  final BiometryRepository _biometryRepository;

  KeyCreationBloc(
    this._nekotonService,
    this._biometryRepository,
  ) : super(KeyCreationStateSuccess());

  @override
  Stream<KeyCreationState> mapEventToState(KeyCreationEvent event) async* {
    try {
      if (event is _Create) {
        final isLegacy = event.phrase.length == 24;
        final mnemonicType = isLegacy ? const MnemonicType.legacy() : const MnemonicType.labs(id: 0);

        late final CreateKeyInput createKeyInput;

        if (isLegacy) {
          createKeyInput = EncryptedKeyCreateInput(
            name: event.name,
            phrase: event.phrase.join(' '),
            mnemonicType: mnemonicType,
            password: Password.explicit(
              password: event.password,
              cacheBehavior: const PasswordCacheBehavior.remove(),
            ),
          );
        } else {
          createKeyInput = DerivedKeyCreateInput.import(
            keyName: event.name,
            phrase: event.phrase.join(' '),
            password: Password.explicit(
              password: event.password,
              cacheBehavior: const PasswordCacheBehavior.remove(),
            ),
          );
        }

        await _addKey(
          createKeyInput: createKeyInput,
          password: event.password,
        );

        yield KeyCreationStateSuccess();
      } else if (event is _Derive) {
        final key = _nekotonService.keys.firstWhere((e) => e.publicKey == event.publicKey);

        if (key.isNotLegacy && key.accountId == 0) {
          final derivedKeys = _nekotonService.keys.where((e) => e.masterKey == key.publicKey);
          final id = derivedKeys.isNotEmpty ? derivedKeys.map((e) => e.nextAccountId).reduce(max) : 1;
          final masterKey = key.publicKey;

          final createKeyInput = DerivedKeyCreateInput.derive(
            keyName: event.name,
            masterKey: masterKey,
            accountId: id,
            password: Password.explicit(
              password: event.password,
              cacheBehavior: const PasswordCacheBehavior.remove(),
            ),
          );

          await _addKey(
            createKeyInput: createKeyInput,
            password: event.password,
          );

          yield KeyCreationStateSuccess();
        } else {
          throw UnknownSignerException();
        }
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield KeyCreationStateError(err);
    }
  }

  Future<void> _addKey({
    required CreateKeyInput createKeyInput,
    required String password,
  }) async {
    final key = await _nekotonService.addKey(createKeyInput);

    if (_biometryRepository.biometryAvailability && _biometryRepository.biometryStatus) {
      await _biometryRepository.setKeyPassword(
        publicKey: key.publicKey,
        password: password,
      );
    }
  }
}

@freezed
class KeyCreationEvent with _$KeyCreationEvent {
  const factory KeyCreationEvent.create({
    String? name,
    required List<String> phrase,
    required String password,
  }) = _Create;

  const factory KeyCreationEvent.derive({
    String? name,
    required String publicKey,
    required String password,
  }) = _Derive;
}

abstract class KeyCreationState {}

class KeyCreationStateInitial extends KeyCreationState {}

class KeyCreationStateSuccess extends KeyCreationState {}

class KeyCreationStateError extends KeyCreationState {
  final Exception exception;

  KeyCreationStateError(this.exception);
}
