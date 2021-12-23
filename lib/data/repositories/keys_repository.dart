import 'dart:math';

import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../services/nekoton_service.dart';
import 'biometry_repository.dart';

@lazySingleton
class KeysRepository {
  final NekotonService _nekotonService;
  final BiometryRepository _biometryRepository;

  KeysRepository(
    this._nekotonService,
    this._biometryRepository,
  );

  Future<KeyStoreEntry> createKey({
    String? name,
    required List<String> phrase,
    required String password,
  }) async {
    final isLegacy = phrase.length == 24;
    final mnemonicType = isLegacy ? const MnemonicType.legacy() : const MnemonicType.labs(id: 0);

    late final CreateKeyInput createKeyInput;

    if (isLegacy) {
      createKeyInput = CreateKeyInput.encryptedKeyCreateInput(
        EncryptedKeyCreateInput(
          name: name,
          phrase: phrase.join(' '),
          mnemonicType: mnemonicType,
          password: Password.explicit(
            password: password,
            cacheBehavior: const PasswordCacheBehavior.remove(),
          ),
        ),
      );
    } else {
      createKeyInput = CreateKeyInput.derivedKeyCreateInput(
        DerivedKeyCreateInput.import(
          keyName: name,
          phrase: phrase.join(' '),
          password: Password.explicit(
            password: password,
            cacheBehavior: const PasswordCacheBehavior.remove(),
          ),
        ),
      );
    }

    return _addKey(
      createKeyInput: createKeyInput,
      password: password,
    );
  }

  Future<KeyStoreEntry> deriveKey({
    String? name,
    required String publicKey,
    required String password,
  }) async {
    final key = _nekotonService.keys.firstWhere((e) => e.publicKey == publicKey);

    if (key.isNotLegacy && key.accountId == 0) {
      final derivedKeys = _nekotonService.keys.where((e) => e.masterKey == key.publicKey);
      final id = derivedKeys.isNotEmpty ? derivedKeys.map((e) => e.nextAccountId).reduce(max) : 1;
      final masterKey = key.publicKey;

      final createKeyInput = CreateKeyInput.derivedKeyCreateInput(
        DerivedKeyCreateInput.derive(
          keyName: name,
          masterKey: masterKey,
          accountId: id,
          password: Password.explicit(
            password: password,
            cacheBehavior: const PasswordCacheBehavior.remove(),
          ),
        ),
      );

      return _addKey(
        createKeyInput: createKeyInput,
        password: password,
      );
    } else {
      throw UnknownSignerException();
    }
  }

  Future<KeyStoreEntry> _addKey({
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

    return key;
  }

  Future<List<String>> exportKey({
    required String publicKey,
    required String password,
  }) async {
    final key = _nekotonService.keys.firstWhereOrNull((e) => e.publicKey == publicKey);

    if (key == null) {
      throw KeyNotFoundException();
    }

    late final ExportKeyInput exportKeyInput;

    if (key.isLegacy) {
      exportKeyInput = ExportKeyInput.encryptedKeyPassword(
        EncryptedKeyPassword(
          publicKey: key.publicKey,
          password: Password.explicit(
            password: password,
            cacheBehavior: const PasswordCacheBehavior.remove(),
          ),
        ),
      );
    } else {
      exportKeyInput = ExportKeyInput.derivedKeyExportParams(
        DerivedKeyExportParams(
          masterKey: key.masterKey,
          password: Password.explicit(
            password: password,
            cacheBehavior: const PasswordCacheBehavior.remove(),
          ),
        ),
      );
    }

    final exportKeyOutput = await _nekotonService.exportKey(exportKeyInput);

    return exportKeyOutput.when(
      derivedKeyExportOutput: (derivedKeyExportOutput) => derivedKeyExportOutput.phrase.split(' '),
      encryptedKeyExportOutput: (encryptedKeyExportOutput) => encryptedKeyExportOutput.phrase.split(' '),
    );
  }

  Future<bool> checkKeyPassword({
    required String publicKey,
    required String password,
  }) {
    final key = _nekotonService.keys.firstWhereOrNull((e) => e.publicKey == publicKey);

    if (key == null) {
      throw KeyNotFoundException();
    }

    late final SignInput signInput;

    if (key.isLegacy) {
      signInput = SignInput.encryptedKeyPassword(
        EncryptedKeyPassword(
          publicKey: key.publicKey,
          password: Password.explicit(
            password: password,
            cacheBehavior: const PasswordCacheBehavior.remove(),
          ),
        ),
      );
    } else {
      signInput = SignInput.derivedKeySignParams(
        DerivedKeySignParams.byAccountId(
          masterKey: key.masterKey,
          accountId: key.accountId,
          password: Password.explicit(
            password: password,
            cacheBehavior: const PasswordCacheBehavior.remove(),
          ),
        ),
      );
    }

    return _nekotonService.checkKeyPassword(signInput);
  }

  Future<KeyStoreEntry?> removeKey(String publicKey) => _nekotonService.removeKey(publicKey);

  Future<KeyStoreEntry> changePassword({
    required String publicKey,
    required String oldPassword,
    required String newPassword,
  }) async {
    final key = _nekotonService.keys.firstWhereOrNull((e) => e.publicKey == publicKey);

    if (key == null) {
      throw KeyNotFoundException();
    }

    late final UpdateKeyInput updateKeyInput;

    if (key.isLegacy) {
      updateKeyInput = UpdateKeyInput.encryptedKeyUpdateParams(
        EncryptedKeyUpdateParams.changePassword(
          publicKey: key.publicKey,
          oldPassword: Password.explicit(
            password: oldPassword,
            cacheBehavior: const PasswordCacheBehavior.remove(),
          ),
          newPassword: Password.explicit(
            password: newPassword,
            cacheBehavior: const PasswordCacheBehavior.remove(),
          ),
        ),
      );
    } else {
      updateKeyInput = UpdateKeyInput.derivedKeyUpdateParams(
        DerivedKeyUpdateParams.changePassword(
          masterKey: key.masterKey,
          oldPassword: Password.explicit(
            password: oldPassword,
            cacheBehavior: const PasswordCacheBehavior.remove(),
          ),
          newPassword: Password.explicit(
            password: newPassword,
            cacheBehavior: const PasswordCacheBehavior.remove(),
          ),
        ),
      );
    }

    final updatedKeyStoreEntry = await _nekotonService.updateKey(updateKeyInput);

    await _biometryRepository.setKeyPassword(
      publicKey: updatedKeyStoreEntry.publicKey,
      password: newPassword,
    );

    return updatedKeyStoreEntry;
  }

  Future<KeyStoreEntry> renameKey({
    required String publicKey,
    required String name,
  }) {
    final key = _nekotonService.keys.firstWhereOrNull((e) => e.publicKey == publicKey);

    if (key == null) {
      throw KeyNotFoundException();
    }

    late final UpdateKeyInput updateKeyInput;

    if (key.isLegacy) {
      updateKeyInput = UpdateKeyInput.encryptedKeyUpdateParams(
        EncryptedKeyUpdateParams.rename(
          publicKey: key.publicKey,
          name: name,
        ),
      );
    } else {
      updateKeyInput = UpdateKeyInput.derivedKeyUpdateParams(
        DerivedKeyUpdateParams.renameKey(
          masterKey: key.masterKey,
          publicKey: key.publicKey,
          name: name,
        ),
      );
    }

    return _nekotonService.updateKey(updateKeyInput);
  }
}
