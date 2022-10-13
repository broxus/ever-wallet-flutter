import 'dart:async';

import 'package:collection/collection.dart';
import 'package:event_bus/event_bus.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/models/key_added_event.dart';
import 'package:ever_wallet/data/models/key_removed_event.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/data/utils.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

class KeysRepository {
  final Keystore _keystore;
  final HiveSource _hiveSource;
  final EventBus _eventBus;

  KeysRepository._({
    required Keystore keystore,
    required HiveSource hiveSource,
    required EventBus eventBus,
  })  : _keystore = keystore,
        _hiveSource = hiveSource,
        _eventBus = eventBus;

  static Future<KeysRepository> create({
    required Keystore keystore,
    required HiveSource hiveSource,
    required EventBus eventBus,
  }) async {
    final instance = KeysRepository._(
      keystore: keystore,
      hiveSource: hiveSource,
      eventBus: eventBus,
    );
    await instance._initialize();
    return instance;
  }

  Stream<List<KeyStoreEntry>> get keysStream => _keystore.entriesStream;

  List<KeyStoreEntry> get keys => _keystore.entries;

  Stream<Map<String, String>> get seedsStream => _hiveSource.seedsStream;

  Map<String, String> get seeds => _hiveSource.seeds;

  Stream<List<KeyStoreEntry>> seedKeysStream(String masterKey) =>
      keysStream.map((e) => e.whereKeysFor(masterKey));

  List<KeyStoreEntry> seedKeys(String masterKey) => keys.whereKeysFor(masterKey);

  Stream<String?> get currentKeyStream => _hiveSource.currentKeyStream;

  String? get currentKey => _hiveSource.currentKey;

  Stream<KeyStoreEntry?> get currentKeyEntryStream =>
      keysStream.map((keys) => keys.firstWhereOrNull((k) => k.publicKey == currentKey));

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
      });

  Future<void> setCurrentKey(String? publicKey) => _hiveSource.setCurrentKey(publicKey);

  Stream<Map<String, String>> get labelsStream =>
      Rx.combineLatest2<Map<String, String>, Map<String, String>, Map<String, String>>(
        _hiveSource.keyLabelsStream,
        keysStream.map((e) => {for (final v in e) v.publicKey: v.name}),
        (a, b) => {...a, ...b},
      );

  Map<String, String> get labels => {
        ..._hiveSource.keyLabels,
        ...{for (final v in keys) v.publicKey: v.name}
      };

  Future<KeyStoreEntry> createKey({
    String? name,
    required List<String> phrase,
    required String password,
  }) async {
    final isLegacy = phrase.length == 24;
    final mnemonicType = isLegacy ? const MnemonicType.legacy() : const MnemonicType.labs(0);
    final phraseStr = phrase.join(' ');

    final CreateKeyInput createKeyInput;

    if (isLegacy) {
      createKeyInput = EncryptedKeyCreateInput(
        name: name,
        phrase: phraseStr,
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
          phrase: phraseStr,
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

    await _hiveSource.addSeed(
      masterKey: key.publicKey,
      name: name ?? defaultSeedName(keys.length + 1),
    );

    await _savePassword(
      publicKey: key.publicKey,
      password: password,
    );

    await _hiveSource.removeKeyLabel(key.publicKey);

    _eventBus.fire(KeyAddedEvent(key));

    return key;
  }

  Future<KeyStoreEntry> deriveKey({
    String? name,
    required String publicKey,
    required int accountId,
    required String password,
  }) async {
    final key = keys.firstWhere((e) => e.publicKey == publicKey);

    if (key.isLegacy || !key.isMaster) throw UnsupportedError('Key is not derivable');

    final createKeyInput = DerivedKeyCreateInput.derive(
      DerivedKeyCreateInputDerive(
        keyName: name,
        masterKey: publicKey,
        accountId: accountId,
        password: Password.explicit(
          PasswordExplicit(
            password: password,
            cacheBehavior: const PasswordCacheBehavior.nop(),
          ),
        ),
      ),
    );

    final derivedKey = await _keystore.addKey(createKeyInput);

    await _savePassword(
      publicKey: derivedKey.publicKey,
      password: password,
    );

    await _hiveSource.removeKeyLabel(derivedKey.publicKey);

    _eventBus.fire(KeyAddedEvent(derivedKey));

    return derivedKey;
  }

  Future<KeyStoreEntry> changePassword({
    required String publicKey,
    required String oldPassword,
    required String newPassword,
  }) async {
    final key = keys.firstWhere((e) => e.publicKey == publicKey);

    final UpdateKeyInput updateKeyInput;

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

    await _savePassword(
      publicKey: updatedKey.publicKey,
      password: newPassword,
    );

    return updatedKey;
  }

  Future<void> renameKey({
    required String publicKey,
    required String name,
  }) async {
    final key = keys.firstWhereOrNull((e) => e.publicKey == publicKey);

    if (key == null) {
      await _hiveSource.setKeyLabel(
        publicKey: publicKey,
        label: name,
      );

      return;
    }

    final UpdateKeyInput updateKeyInput;

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
    final key = keys.firstWhere((e) => e.publicKey == publicKey);

    final ExportKeyInput exportKeyInput;

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

    final List<String> phrase;

    if (exportKeyInput is EncryptedKeyPassword) {
      phrase = (exportKeyOutput as EncryptedKeyExportOutput).phrase.split(' ');
    } else if (exportKeyInput is DerivedKeyExportParams) {
      phrase = (exportKeyOutput as DerivedKeyExportOutput).phrase.split(' ');
    } else {
      throw UnsupportedError('Invalid signer');
    }

    await _savePassword(
      publicKey: key.publicKey,
      password: password,
    );

    return phrase;
  }

  Future<List<EncryptedData>> encrypt({
    required String data,
    required List<String> publicKeys,
    required EncryptionAlgorithm algorithm,
    required String publicKey,
    required String password,
  }) async {
    final key = keys.firstWhere((e) => e.publicKey == publicKey);

    final input = key.signInput(password);

    final encryptedData = await _keystore.encrypt(
      data: data,
      publicKeys: publicKeys,
      algorithm: algorithm,
      input: input,
    );

    await _savePassword(
      publicKey: key.publicKey,
      password: password,
    );

    return encryptedData;
  }

  Future<String> decrypt({
    required EncryptedData data,
    required String publicKey,
    required String password,
  }) async {
    final key = keys.firstWhere((e) => e.publicKey == publicKey);

    final input = key.signInput(password);

    final decryptedData = await _keystore.decrypt(
      data: data,
      input: input,
    );

    await _savePassword(
      publicKey: key.publicKey,
      password: password,
    );

    return decryptedData;
  }

  Future<String> sign({
    required String data,
    required String publicKey,
    required String password,
  }) async {
    final key = keys.firstWhere((e) => e.publicKey == publicKey);

    final input = key.signInput(password);

    final signature = await _keystore.sign(
      data: data,
      input: input,
    );

    await _savePassword(
      publicKey: key.publicKey,
      password: password,
    );

    return signature;
  }

  Future<SignedData> signData({
    required String data,
    required String publicKey,
    required String password,
  }) async {
    final key = keys.firstWhere((e) => e.publicKey == publicKey);

    final input = key.signInput(password);

    final signedData = await _keystore.signData(
      data: data,
      input: input,
    );

    await _savePassword(
      publicKey: key.publicKey,
      password: password,
    );

    return signedData;
  }

  Future<SignedDataRaw> signDataRaw({
    required String data,
    required String publicKey,
    required String password,
  }) async {
    final key = keys.firstWhere((e) => e.publicKey == publicKey);

    final input = key.signInput(password);

    final signedData = await _keystore.signDataRaw(
      data: data,
      input: input,
    );

    await _savePassword(
      publicKey: key.publicKey,
      password: password,
    );

    return signedData;
  }

  Future<bool> checkKeyPassword({
    required String publicKey,
    required String password,
  }) async {
    final key = keys.firstWhere((e) => e.publicKey == publicKey);

    final input = key.signInput(password);

    try {
      await _keystore.sign(data: fakeSignature(), input: input);

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<KeyStoreEntry> removeKey(String publicKey) async {
    final key = keys.firstWhere((e) => e.publicKey == publicKey);

    final removedKeys = <KeyStoreEntry>[];

    if (key.isNotLegacy && key.isMaster) {
      final derivedKeys = keys.where((e) => e.masterKey == publicKey);

      removedKeys.addAll(await _keystore.removeKeys(derivedKeys.map((e) => e.publicKey).toList()));
    }

    final removedKey = (await _keystore.removeKey(key.publicKey))!;

    removedKeys.add(removedKey);

    for (final removedKey in removedKeys) {
      await _hiveSource.removeKeyPassword(removedKey.publicKey);

      _eventBus.fire(KeyRemovedEvent(removedKey));
    }

    if (removedKey.isMaster) await _hiveSource.removeSeed(key.publicKey);

    await _updateCurrentKey();

    return removedKey;
  }

  Future<void> clear() async {
    await _keystore.clear();

    await _hiveSource.clearSeeds();
    await _hiveSource.clearKeyPasswords();
    await _hiveSource.clearKeyLabels();
  }

  Future<void> dispose() => _keystore.dispose();

  Future<void> _savePassword({
    required String publicKey,
    required String password,
  }) async {
    if (_hiveSource.isBiometryEnabled) {
      await _hiveSource.setKeyPassword(
        publicKey: publicKey,
        password: password,
      );
    }
  }

  Future<void> _updateCurrentKey() async {
    if (!keys.any((e) => e.publicKey == currentKey)) {
      await setCurrentKey(keys.firstOrNull?.publicKey);
    }
  }

  Future<void> _initialize() => _updateCurrentKey();
}

extension on List<KeyStoreEntry> {
  List<KeyStoreEntry> whereKeysFor(String masterKey) => [
        firstWhere((e) => e.publicKey == masterKey),
        ...where((e) => e.masterKey == masterKey).toList(),
      ];
}
