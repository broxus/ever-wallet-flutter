import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/sources/local/current_key_source.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

class KeysRepository {
  final _lock = Lock();
  final Keystore _keystore;
  final CurrentKeySource _currentKeySource;
  final HiveSource _hiveSource;
  final _labelsSubject = BehaviorSubject<Map<String, String>>.seeded({});
  late final StreamSubscription _keysStreamSubscription;

  KeysRepository._(
    this._keystore,
    this._currentKeySource,
    this._hiveSource,
  );

  static Future<KeysRepository> create({
    required Keystore keystore,
    required CurrentKeySource currentKeySource,
    required HiveSource hiveSource,
  }) async {
    final instance = KeysRepository._(
      keystore,
      currentKeySource,
      hiveSource,
    );
    await instance._initialize();
    return instance;
  }

  Stream<List<KeyStoreEntry>> get keysStream => _keystore.entriesStream;

  List<KeyStoreEntry> get keys => _keystore.entries;

  Stream<KeyStoreEntry?> get currentKeyStream => _currentKeySource.currentKeyStream;

  KeyStoreEntry? get currentKey => _currentKeySource.currentKey;

  Stream<KeyStoreEntry> keyInfoStream(String publicKey) => keysStream
      .expand((e) => e)
      .where((e) => e.publicKey == publicKey)
      .doOnError((err, st) => logger.e(err, err, st));

  Stream<Map<KeyStoreEntry, List<KeyStoreEntry>?>> get mappedKeysStream => keysStream.map((e) {
        final map = <KeyStoreEntry, List<KeyStoreEntry>?>{};

        for (final key in e) {
          if (key.publicKey == key.masterKey) {
            if (!map.containsKey(key)) map[key] = null;
          } else {
            final parentKey = e.firstWhereOrNull((e) => e.publicKey == key.masterKey);

            if (parentKey != null) {
              if (map[parentKey] != null) {
                map[parentKey]!.addAll([key]);
              } else {
                map[parentKey] = [key];
              }
            }
          }
        }

        return map;
      }).doOnError((err, st) => logger.e(err, err, st));

  Stream<Map<String, String>> get labelsStream =>
      Rx.combineLatest2<Map<String, String>, Map<String, String>, Map<String, String>>(
        _keystore.entriesStream.map((e) => {for (final v in e) v.publicKey: v.name}),
        _labelsSubject,
        (a, b) => {...b, ...a},
      ).distinct((a, b) => mapEquals(a, b));

  Future<void> setCurrentKey(KeyStoreEntry? currentKey) async {
    await _hiveSource.setCurrentPublicKey(currentKey?.publicKey);

    _currentKeySource.currentKey = currentKey;
  }

  Future<KeyStoreEntry> createKey({
    String? name,
    required List<String> phrase,
    required String password,
  }) async {
    final isLegacy = phrase.length == 24;
    final mnemonicType = isLegacy ? const MnemonicType.legacy() : kDefaultMnemonicType;

    late final CreateKeyInput createKeyInput;

    if (isLegacy) {
      createKeyInput = EncryptedKeyCreateInput(
        name: name,
        phrase: phrase.join(' '),
        mnemonicType: mnemonicType,
        password: Password.explicit(
          PasswordExplicit(
            password: password,
            cacheBehavior: const PasswordCacheBehavior.nop(),
          ),
        ),
      );
    } else {
      createKeyInput = DerivedKeyCreateInput.import(
        DerivedKeyCreateInputImport(
          keyName: name,
          phrase: phrase.join(' '),
          password: Password.explicit(
            PasswordExplicit(
              password: password,
              cacheBehavior: const PasswordCacheBehavior.nop(),
            ),
          ),
        ),
      );
    }

    final key = await _keystore.addKey(createKeyInput);

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
        DerivedKeyCreateInputDerive(
          keyName: name,
          masterKey: masterKey,
          accountId: id,
          password: Password.explicit(
            PasswordExplicit(
              password: password,
              cacheBehavior: const PasswordCacheBehavior.nop(),
            ),
          ),
        ),
      );

      final derivedKey = await _keystore.addKey(createKeyInput);

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
        EncryptedKeyUpdateParamsChangePassword(
          publicKey: key.publicKey,
          oldPassword: Password.explicit(
            PasswordExplicit(
              password: oldPassword,
              cacheBehavior: const PasswordCacheBehavior.nop(),
            ),
          ),
          newPassword: Password.explicit(
            PasswordExplicit(
              password: newPassword,
              cacheBehavior: const PasswordCacheBehavior.nop(),
            ),
          ),
        ),
      );
    } else {
      updateKeyInput = DerivedKeyUpdateParams.changePassword(
        DerivedKeyUpdateParamsChangePassword(
          masterKey: key.masterKey,
          oldPassword: Password.explicit(
            PasswordExplicit(
              password: oldPassword,
              cacheBehavior: const PasswordCacheBehavior.nop(),
            ),
          ),
          newPassword: Password.explicit(
            PasswordExplicit(
              password: newPassword,
              cacheBehavior: const PasswordCacheBehavior.nop(),
            ),
          ),
        ),
      );
    }

    final updatedKey = await _keystore.updateKey(updateKeyInput);

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
        EncryptedKeyUpdateParamsRename(
          publicKey: key.publicKey,
          name: name,
        ),
      );
    } else {
      updateKeyInput = DerivedKeyUpdateParams.renameKey(
        DerivedKeyUpdateParamsRenameKey(
          masterKey: key.masterKey,
          publicKey: key.publicKey,
          name: name,
        ),
      );
    }

    await _keystore.updateKey(updateKeyInput);
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
          PasswordExplicit(
            password: password,
            cacheBehavior: const PasswordCacheBehavior.nop(),
          ),
        ),
      );
    } else {
      exportKeyInput = DerivedKeyExportParams(
        masterKey: key.masterKey,
        password: Password.explicit(
          PasswordExplicit(
            password: password,
            cacheBehavior: const PasswordCacheBehavior.nop(),
          ),
        ),
      );
    }

    final exportKeyOutput = await _keystore.exportKey(exportKeyInput);

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
    final input = _keystore.entries.firstWhere((e) => e.publicKey == publicKey).signInput(password);

    return _keystore.encrypt(
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
    final input = _keystore.entries.firstWhere((e) => e.publicKey == publicKey).signInput(password);

    return _keystore.decrypt(
      data: data,
      input: input,
    );
  }

  Future<String> sign({
    required String data,
    required String publicKey,
    required String password,
  }) {
    final input = _keystore.entries.firstWhere((e) => e.publicKey == publicKey).signInput(password);

    return _keystore.sign(
      data: data,
      input: input,
    );
  }

  Future<SignedData> signData({
    required String data,
    required String publicKey,
    required String password,
  }) {
    final input = _keystore.entries.firstWhere((e) => e.publicKey == publicKey).signInput(password);

    return _keystore.signData(
      data: data,
      input: input,
    );
  }

  Future<SignedDataRaw> signDataRaw({
    required String data,
    required String publicKey,
    required String password,
  }) {
    final input = _keystore.entries.firstWhere((e) => e.publicKey == publicKey).signInput(password);

    return _keystore.signDataRaw(
      data: data,
      input: input,
    );
  }

  Future<bool> checkKeyPassword({
    required String publicKey,
    required String password,
  }) async {
    final input = _keystore.entries.firstWhere((e) => e.publicKey == publicKey).signInput(password);

    try {
      final data = base64.encode(List.generate(kSignatureLength, (_) => 0));

      await _keystore.sign(data: data, input: input);

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<KeyStoreEntry?> removeKey(String publicKey) async {
    final key = await _keystore.removeKey(publicKey);

    final derivedKeys = _keystore.entries.where((e) => e.masterKey == publicKey);

    await _keystore.removeKeys(derivedKeys.map((e) => e.publicKey).toList());

    return key;
  }

  Future<void> clear() async {
    await _hiveSource.clearPublicKeysLabels();

    _labelsSubject.add(_hiveSource.publicKeysLabels);

    await _keystore.clear();
  }

  Future<void> dispose() async {
    await _keysStreamSubscription.cancel();

    await _labelsSubject.close();
  }

  Future<void> _initialize() async {
    final currentPublicKey = _hiveSource.currentPublicKey;

    final currentKey = _keystore.entries.firstWhereOrNull((e) => e.publicKey == currentPublicKey);

    if (currentKey != null) {
      _currentKeySource.currentKey = currentKey;
    } else {
      await setCurrentKey(_keystore.entries.firstOrNull);
    }

    _labelsSubject.add(_hiveSource.publicKeysLabels);

    _keysStreamSubscription =
        keysStream.listen((event) => _lock.synchronized(() => _keysStreamListener(event)));
  }

  Future<void> _keysStreamListener(List<KeyStoreEntry> event) async {
    try {
      if (currentKey == null || !event.contains(currentKey)) {
        await setCurrentKey(_keystore.entries.firstOrNull);
      }

      final duplicatedPublicKeys =
          _hiveSource.publicKeysLabels.keys.where((e) => event.any((el) => e == el.publicKey));

      for (final duplicatedPublicKey in duplicatedPublicKeys) {
        await _hiveSource.removePublicKeyLabel(duplicatedPublicKey);

        _labelsSubject.add(_hiveSource.publicKeysLabels);
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
