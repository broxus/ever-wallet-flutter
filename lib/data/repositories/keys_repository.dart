import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

import '../../logger.dart';
import '../extensions.dart';
import '../sources/local/hive_source.dart';
import '../sources/local/keystore_source.dart';

@preResolve
@lazySingleton
class KeysRepository {
  final KeystoreSource _keystoreSource;
  final HiveSource _hiveSource;
  final _labelsSubject = BehaviorSubject<Map<String, String>>.seeded({});
  final _lock = Lock();

  KeysRepository._(
    this._keystoreSource,
    this._hiveSource,
  );

  @factoryMethod
  static Future<KeysRepository> create({
    required KeystoreSource keystoreSource,
    required HiveSource hiveSource,
  }) async {
    final instance = KeysRepository._(
      keystoreSource,
      hiveSource,
    );
    await instance._initialize();
    return instance;
  }

  Stream<List<KeyStoreEntry>> get keysStream => _keystoreSource.keysStream;

  List<KeyStoreEntry> get keys => _keystoreSource.keys;

  Stream<KeyStoreEntry?> get currentKeyStream => _keystoreSource.currentKeyStream;

  KeyStoreEntry? get currentKey => _keystoreSource.currentKey;

  Stream<Map<String, String>> get labelsStream =>
      Rx.combineLatest2<Map<String, String>, Map<String, String>, Map<String, String>>(
        _keystoreSource.keysStream.map((e) => {for (final v in e) v.publicKey: v.name}),
        _labelsSubject,
        (a, b) => {...b, ...a},
      ).distinct((a, b) => mapEquals(a, b));

  Future<void> setCurrentKey(KeyStoreEntry? currentKey) async {
    await _hiveSource.setCurrentPublicKey(currentKey?.publicKey);

    _keystoreSource.currentKey = currentKey;
  }

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

    final key = await _keystoreSource.addKey(createKeyInput);

    if (_hiveSource.isBiometryEnabled) {
      await _hiveSource.setKeyPassword(
        publicKey: key.publicKey,
        password: password,
      );
    }

    return key;
  }

  Future<KeyStoreEntry> deriveKey({
    String? name,
    required String publicKey,
    required String password,
  }) async {
    final key = keys.firstWhereOrNull((e) => e.publicKey == publicKey);

    if (key == null) throw Exception('Key is not found');

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

      final derivedKey = await _keystoreSource.addKey(createKeyInput);

      if (_hiveSource.isBiometryEnabled) {
        await _hiveSource.setKeyPassword(
          publicKey: derivedKey.publicKey,
          password: password,
        );
      }

      return derivedKey;
    } else {
      throw Exception('Key is not derivable');
    }
  }

  Future<KeyStoreEntry> changePassword({
    required String publicKey,
    required String oldPassword,
    required String newPassword,
  }) async {
    final key = keys.firstWhereOrNull((e) => e.publicKey == publicKey);

    if (key == null) throw Exception('Key is not found');

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

    final updatedKey = await _keystoreSource.updateKey(updateKeyInput);

    if (_hiveSource.isBiometryEnabled) {
      await _hiveSource.setKeyPassword(
        publicKey: updatedKey.publicKey,
        password: newPassword,
      );
    }

    return updatedKey;
  }

  Future<void> renameKey({
    required String publicKey,
    required String name,
  }) async {
    final key = keys.firstWhereOrNull((e) => e.publicKey == publicKey);

    if (key == null) {
      await _hiveSource.setPublicKeyLabel(
        publicKey: publicKey,
        label: name,
      );

      _labelsSubject.add(_hiveSource.publicKeysLabels);

      return;
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

    await _keystoreSource.updateKey(updateKeyInput);
  }

  Future<List<String>> exportKey({
    required String publicKey,
    required String password,
  }) async {
    final key = keys.firstWhereOrNull((e) => e.publicKey == publicKey);

    if (key == null) throw Exception('Key is not found');

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

    final exportKeyOutput = await _keystoreSource.exportKey(exportKeyInput);

    late final List<String> phrase;

    if (exportKeyInput is EncryptedKeyPassword) {
      phrase = (exportKeyOutput as EncryptedKeyExportOutput).phrase.split(' ');
    } else if (exportKeyInput is DerivedKeyExportParams) {
      phrase = (exportKeyOutput as DerivedKeyExportOutput).phrase.split(' ');
    } else {
      throw Exception('Unknown signer');
    }

    return phrase;
  }

  Future<List<EncryptedData>> encrypt({
    required String data,
    required List<String> publicKeys,
    required EncryptionAlgorithm algorithm,
    required String publicKey,
    required String password,
  }) {
    final input = _keystoreSource.keys.firstWhere((e) => e.publicKey == publicKey).signInput(password);

    return _keystoreSource.encrypt(
      data: data,
      publicKeys: publicKeys,
      algorithm: algorithm,
      input: input,
    );
  }

  Future<String> decrypt({
    required EncryptedData data,
    required String publicKey,
    required String password,
  }) {
    final input = _keystoreSource.keys.firstWhere((e) => e.publicKey == publicKey).signInput(password);

    return _keystoreSource.decrypt(
      data: data,
      input: input,
    );
  }

  Future<String> sign({
    required String data,
    required String publicKey,
    required String password,
  }) {
    final input = _keystoreSource.keys.firstWhere((e) => e.publicKey == publicKey).signInput(password);

    return _keystoreSource.sign(
      data: data,
      input: input,
    );
  }

  Future<SignedData> signData({
    required String data,
    required String publicKey,
    required String password,
  }) {
    final input = _keystoreSource.keys.firstWhere((e) => e.publicKey == publicKey).signInput(password);

    return _keystoreSource.signData(
      data: data,
      input: input,
    );
  }

  Future<SignedDataRaw> signDataRaw({
    required String data,
    required String publicKey,
    required String password,
  }) {
    final input = _keystoreSource.keys.firstWhere((e) => e.publicKey == publicKey).signInput(password);

    return _keystoreSource.signDataRaw(
      data: data,
      input: input,
    );
  }

  Future<bool> checkKeyPassword({
    required String publicKey,
    required String password,
  }) async {
    final input = _keystoreSource.keys.firstWhere((e) => e.publicKey == publicKey).signInput(password);

    try {
      final data = base64.encode(List.generate(kSignatureLength, (_) => 0));

      await _keystoreSource.sign(data: data, input: input);

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<KeyStoreEntry?> removeKey(String publicKey) async {
    final key = await _keystoreSource.removeKey(publicKey);

    final derivedKeys = _keystoreSource.keys.where((e) => e.masterKey == publicKey);

    await _keystoreSource.removeKeys(derivedKeys.map((e) => e.publicKey).toList());

    return key;
  }

  Future<void> clear() async {
    await _hiveSource.clearPublicKeysLabels();

    _labelsSubject.add(_hiveSource.publicKeysLabels);

    await _keystoreSource.clear();
  }

  Future<void> _initialize() async {
    final currentPublicKey = _hiveSource.currentPublicKey;

    final currentKey = _keystoreSource.keys.firstWhereOrNull((e) => e.publicKey == currentPublicKey);

    if (currentKey != null) {
      _keystoreSource.currentKey = currentKey;
    } else {
      await setCurrentKey(_keystoreSource.keys.firstOrNull);
    }

    _labelsSubject.add(_hiveSource.publicKeysLabels);

    keysStream.listen((event) => _lock.synchronized(() => _keysStreamListener(event)));
  }

  Future<void> _keysStreamListener(List<KeyStoreEntry> event) async {
    try {
      if (currentKey == null || !event.contains(currentKey)) {
        await setCurrentKey(_keystoreSource.keys.firstOrNull);
      }

      final duplicatedPublicKeys = _hiveSource.publicKeysLabels.keys.where((e) => event.any((el) => e == el.publicKey));

      for (final duplicatedPublicKey in duplicatedPublicKeys) {
        await _hiveSource.removePublicKeyLabel(duplicatedPublicKey);

        _labelsSubject.add(_hiveSource.publicKeysLabels);
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
