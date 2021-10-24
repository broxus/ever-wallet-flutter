import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../repositories/biometry_repository.dart';
import '../../services/nekoton_service.dart';

part 'key_creation_bloc.freezed.dart';

@injectable
class KeyCreationBloc extends Bloc<KeyCreationEvent, KeyCreationState> {
  final NekotonService _nekotonService;
  final BiometryRepository _biometryRepository;
  final _errorsSubject = PublishSubject<String>();

  KeyCreationBloc(
    this._nekotonService,
    this._biometryRepository,
  ) : super(const KeyCreationState.initial());

  @override
  Future<void> close() {
    _errorsSubject.close();
    return super.close();
  }

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
            phrase: event.phrase.join(" "),
            mnemonicType: mnemonicType,
            password: Password.explicit(
              password: event.password,
              cacheBehavior: const PasswordCacheBehavior.remove(),
            ),
          );
        } else {
          createKeyInput = DerivedKeyCreateInput.import(
            keyName: event.name,
            phrase: event.phrase.join(" "),
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

        yield const KeyCreationState.success();
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

          yield const KeyCreationState.success();
        } else {
          throw UnsupportedError("Operation is unsupported");
        }
      }
    } catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err.toString());
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

  Stream<String> get errorsStream => _errorsSubject.stream;
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

@freezed
class KeyCreationState with _$KeyCreationState {
  const factory KeyCreationState.initial() = _Initial;

  const factory KeyCreationState.success() = _Success;
}
