import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../sources/local/nekoton_source.dart';
import 'biometry_repository.dart';

@preResolve
@lazySingleton
class KeystoreRepository {
  late final Keystore keystore;
  final NekotonSource _nekotonSource;
  final BiometryRepository _biometryRepository;
  final _keysSubject = BehaviorSubject<List<KeyStoreEntry>>.seeded([]);

  KeystoreRepository._(
    this._nekotonSource,
    this._biometryRepository,
  );

  @factoryMethod
  static Future<KeystoreRepository> create({
    required NekotonSource nekotonSource,
    required BiometryRepository biometryRepository,
  }) async {
    final keystoreRepository = KeystoreRepository._(
      nekotonSource,
      biometryRepository,
    );
    await keystoreRepository._initialize();
    return keystoreRepository;
  }

  Stream<List<KeyStoreEntry>> get keysStream => _keysSubject.stream.distinct((a, b) => listEquals(a, b));

  List<KeyStoreEntry> get keys => _keysSubject.value;

  Future<KeyStoreEntry> createKey({
    String? name,
    required List<String> phrase,
    required String password,
  }) async {
    final isLegacy = phrase.length == 24;
    final mnemonicType = isLegacy ? const MnemonicType.legacy() : const MnemonicType.labs(id: 0);

    late final CreateKeyInput createKeyInput;

    if (isLegacy) {
      createKeyInput = EncryptedKeyCreateInput(
        name: name,
        phrase: phrase.join(' '),
        mnemonicType: mnemonicType,
        password: Password.explicit(
          password: password,
          cacheBehavior: const PasswordCacheBehavior.remove(),
        ),
      );
    } else {
      createKeyInput = DerivedKeyCreateInput.import(
        keyName: name,
        phrase: phrase.join(' '),
        password: Password.explicit(
          password: password,
          cacheBehavior: const PasswordCacheBehavior.remove(),
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
    final key = keys.firstWhere((e) => e.publicKey == publicKey);

    if (key.isNotLegacy && key.accountId == 0) {
      final derivedKeys = keys.where((e) => e.masterKey == key.publicKey);
      final id = derivedKeys.isNotEmpty ? derivedKeys.map((e) => e.accountId + 1).reduce(max) : 1;
      final masterKey = key.publicKey;

      final createKeyInput = DerivedKeyCreateInput.derive(
        keyName: name,
        masterKey: masterKey,
        accountId: id,
        password: Password.explicit(
          password: password,
          cacheBehavior: const PasswordCacheBehavior.remove(),
        ),
      );

      return _addKey(
        createKeyInput: createKeyInput,
        password: password,
      );
    } else {
      throw Exception('Key is not derivable');
    }
  }

  Future<KeyStoreEntry> _addKey({
    required CreateKeyInput createKeyInput,
    required String password,
  }) async {
    final key = await keystore.addKey(createKeyInput);

    _keysSubject.add(await keystore.entries);

    if (_biometryRepository.biometryAvailability && _biometryRepository.biometryStatus) {
      await _biometryRepository.setKeyPassword(
        publicKey: key.publicKey,
        password: password,
      );
    }

    return key;
  }

  Future<KeyStoreEntry> changePassword({
    required String publicKey,
    required String oldPassword,
    required String newPassword,
  }) async {
    final key = keys.firstWhereOrNull((e) => e.publicKey == publicKey);

    if (key == null) {
      throw Exception('Key is not found');
    }

    late final UpdateKeyInput updateKeyInput;

    if (key.isLegacy) {
      updateKeyInput = EncryptedKeyUpdateParams.changePassword(
        publicKey: key.publicKey,
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
        masterKey: key.masterKey,
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

    final updatedKeyStoreEntry = await _updateKey(updateKeyInput);

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
    final key = keys.firstWhereOrNull((e) => e.publicKey == publicKey);

    if (key == null) {
      throw Exception('Key is not found');
    }

    late final UpdateKeyInput updateKeyInput;

    if (key.isLegacy) {
      updateKeyInput = EncryptedKeyUpdateParams.rename(
        publicKey: key.publicKey,
        name: name,
      );
    } else {
      updateKeyInput = DerivedKeyUpdateParams.renameKey(
        masterKey: key.masterKey,
        publicKey: key.publicKey,
        name: name,
      );
    }

    return _updateKey(updateKeyInput);
  }

  Future<KeyStoreEntry> _updateKey(UpdateKeyInput updateKeyInput) async {
    final key = await keystore.updateKey(updateKeyInput);

    _keysSubject.add(await keystore.entries);

    return key;
  }

  Future<List<String>> exportKey({
    required String publicKey,
    required String password,
  }) async {
    final key = keys.firstWhereOrNull((e) => e.publicKey == publicKey);

    if (key == null) {
      throw Exception('Key is not found');
    }

    late final ExportKeyInput exportKeyInput;

    if (key.isLegacy) {
      exportKeyInput = EncryptedKeyPassword(
        publicKey: key.publicKey,
        password: Password.explicit(
          password: password,
          cacheBehavior: const PasswordCacheBehavior.remove(),
        ),
      );
    } else {
      exportKeyInput = DerivedKeyExportParams(
        masterKey: key.masterKey,
        password: Password.explicit(
          password: password,
          cacheBehavior: const PasswordCacheBehavior.remove(),
        ),
      );
    }

    final exportKeyOutput = await keystore.exportKey(exportKeyInput);

    if (exportKeyInput is EncryptedKeyPassword) {
      return (exportKeyOutput as EncryptedKeyExportOutput).phrase.split(' ');
    } else if (exportKeyInput is DerivedKeyExportParams) {
      return (exportKeyOutput as DerivedKeyExportOutput).phrase.split(' ');
    } else {
      throw Exception('Unknown signer');
    }
  }

  Future<bool> checkKeyPassword({
    required String publicKey,
    required String password,
  }) {
    final key = keys.firstWhereOrNull((e) => e.publicKey == publicKey);

    if (key == null) {
      throw Exception('Key is not found');
    }

    late final SignInput signInput;

    if (key.isLegacy) {
      signInput = EncryptedKeyPassword(
        publicKey: key.publicKey,
        password: Password.explicit(
          password: password,
          cacheBehavior: const PasswordCacheBehavior.remove(),
        ),
      );
    } else {
      signInput = DerivedKeySignParams.byAccountId(
        masterKey: key.masterKey,
        accountId: key.accountId,
        password: Password.explicit(
          password: password,
          cacheBehavior: const PasswordCacheBehavior.remove(),
        ),
      );
    }

    return keystore.checkKeyPassword(signInput);
  }

  Future<KeyStoreEntry?> removeKey(String publicKey) async {
    final key = await keystore.removeKey(publicKey);

    _keysSubject.add(await keystore.entries);

    final derivedKeys = _keysSubject.value.where((e) => e.masterKey == publicKey);

    for (final key in derivedKeys) {
      await keystore.removeKey(key.publicKey);

      _keysSubject.add(await keystore.entries);
    }

    return key;
  }

  Future<void> clear() async {
    await keystore.clear();

    _keysSubject.add(await keystore.entries);
  }

  Future<void> _initialize() async {
    keystore = await Keystore.create(_nekotonSource.storage);

    _keysSubject.add(await keystore.entries);
  }
}
