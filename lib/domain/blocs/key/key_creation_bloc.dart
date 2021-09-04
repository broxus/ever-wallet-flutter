import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../repositories/biometry_repository.dart';
import '../../services/nekoton_service.dart';

part 'key_creation_bloc.freezed.dart';

@injectable
class KeyCreationBloc extends Bloc<KeyCreationEvent, KeyCreationState> {
  final NekotonService _nekotonService;
  final BiometryRepository _biometryRepository;

  KeyCreationBloc(
    this._nekotonService,
    this._biometryRepository,
  ) : super(const KeyCreationState.initial());

  @override
  Stream<KeyCreationState> mapEventToState(KeyCreationEvent event) async* {
    yield* event.when(
      createKey: (
        String? name,
        List<String> phrase,
        String password,
      ) async* {
        try {
          final isLegacy = phrase.length == 24;
          final mnemonicType = isLegacy ? const MnemonicType.legacy() : const MnemonicType.labs(id: 0);

          late final CreateKeyInput createKeyInput;

          if (isLegacy) {
            createKeyInput = EncryptedKeyCreateInput(
              name: name,
              phrase: phrase.join(" "),
              mnemonicType: mnemonicType,
              password: Password.explicit(
                password: password,
                cacheBehavior: const PasswordCacheBehavior.remove(),
              ),
            );
          } else {
            createKeyInput = DerivedKeyCreateInput.import(
              keyName: name,
              phrase: phrase.join(" "),
              password: Password.explicit(
                password: password,
                cacheBehavior: const PasswordCacheBehavior.remove(),
              ),
            );
          }

          await _addKey(
            createKeyInput: createKeyInput,
            password: password,
          );

          yield const KeyCreationState.success();
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield KeyCreationState.error(err.toString());
        }
      },
      deriveKey: (
        String? name,
        KeySubject keySubject,
        String password,
      ) async* {
        try {
          if (keySubject.value.isNotLegacy && keySubject.value.accountId == 0) {
            final derivedKeys =
                _nekotonService.keys.map((e) => e.value).where((e) => e.masterKey == keySubject.value.publicKey);
            final id = derivedKeys.isNotEmpty ? derivedKeys.map((e) => e.nextAccountId).reduce(max) : 1;
            final masterKey = keySubject.value.publicKey;

            final createKeyInput = DerivedKeyCreateInput.derive(
              keyName: name,
              masterKey: masterKey,
              accountId: id,
              password: Password.explicit(
                password: password,
                cacheBehavior: const PasswordCacheBehavior.remove(),
              ),
            );

            await _addKey(
              createKeyInput: createKeyInput,
              password: password,
            );

            yield const KeyCreationState.success();
          } else {
            throw UnimplementedError();
          }
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield KeyCreationState.error(err.toString());
        }
      },
    );
  }

  Future<void> _addKey({
    required CreateKeyInput createKeyInput,
    required String password,
  }) async {
    final key = await _nekotonService.addKey(createKeyInput);

    await _biometryRepository.setKeyPassword(
      publicKey: key.value.publicKey,
      password: password,
    );

    await _nekotonService.findAndSubscribeToExistingWallets(key.value.publicKey);
  }
}

@freezed
class KeyCreationEvent with _$KeyCreationEvent {
  const factory KeyCreationEvent.createKey({
    String? name,
    required List<String> phrase,
    required String password,
  }) = _CreateKey;

  const factory KeyCreationEvent.deriveKey({
    String? name,
    required KeySubject keySubject,
    required String password,
  }) = _DeriveKey;
}

@freezed
class KeyCreationState with _$KeyCreationState {
  const factory KeyCreationState.initial() = _Initial;

  const factory KeyCreationState.success() = _Success;

  const factory KeyCreationState.error(String info) = _Error;
}
