import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:event_bus/event_bus.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/models/key_added_event.dart';
import 'package:ever_wallet/data/models/key_removed_event.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/data/utils.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

/// Repository that stores, manipulate and provide information about keys/seeds
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
    await instance._tryNamesMigration();
    return instance;
  }

  /// Equivalent of [keys] with stream
  Stream<List<KeyStoreEntry>> get keysStream => _keystore.entriesStream;

  /// Get list of all keys
  List<KeyStoreEntry> get keys => _keystore.entries;

  /// Equivalent of [seeds] with stream
  Stream<Map<String, String>> get seedsStream => _hiveSource.seedsStream;

  /// Dictionary of seed keys where key - public key of seed, value - its name (label)
  Map<String, String> get seeds => _hiveSource.seeds;

  /// Equivalent of [seedKeys] with stream
  Stream<List<KeyStoreEntry>> seedKeysStream(String masterKey) =>
      keysStream.map((e) => e.whereKeysFor(masterKey));

  /// Get list of sub(derived) keys from [masterKey]
  List<KeyStoreEntry> seedKeys(String masterKey) => keys.whereKeysFor(masterKey);

  /// Equivalent of [currentKey] with stream
  Stream<String?> get currentKeyStream => _hiveSource.currentKeyStream;

  /// Returns publicKey of currently activated key
  String? get currentKey => _hiveSource.currentKey;

  /// Equivalent of [currentKeyStream] but with blockchain representation of object
  Stream<KeyStoreEntry?> get currentKeyEntryStream =>
      currentKeyStream.map((current) => keys.firstWhereOrNull((k) => k.publicKey == current));

  /// See [HiveSource.lastViewedSeedsStream]
  Stream<List<KeyStoreEntry>> lastViewedKeysStream() => _hiveSource.lastViewedSeedsStream().map(
        (viewed) => viewed
            .map((v) => keys.firstWhereOrNull((k) => k.publicKey == v))
            .whereNotNull()
            .toList(),
      );

  /// See [HiveSource.lastViewedSeeds]
  List<KeyStoreEntry> lastViewedKeys() => _hiveSource
      .lastViewedSeeds()
      .map((viewed) => keys.firstWhereOrNull((key) => viewed == key.publicKey))
      .whereNotNull()
      .toList();

  /// Get master key of newly selected [publicKey], then put master key to 0 position in last viewed,
  /// crop list and save.
  Future<void> _updateLastViewed(String publicKey) {
    final master = keys.masterFor(publicKey);
    final viewed = lastViewedKeys()..insert(0, master);
    return _hiveSource.updateLastViewedSeeds(
      LinkedHashSet<KeyStoreEntry>.from(viewed)
          .take(maxLastSelectedSeeds)
          .map((e) => e.publicKey)
          .toList(),
    );
  }

  /// All keys mapped by: key - keyEntry that is master, value - list of sub keyEntries of master
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

  /// Change currently active key
  Future<void> setCurrentKey(String? publicKey) {
    if (publicKey != null) _updateLastViewed(publicKey);
    return _hiveSource.setCurrentKey(publicKey);
  }

  /// Equivalent of [keyLabels] with stream
  Stream<Map<String, String>> get keyLabelsStream =>
      keysStream.map((e) => {for (final v in e) v.publicKey: v.name});

  /// Dictionary of publicKey (key) - key label
  Map<String, String> get keyLabels => {for (final v in keys) v.publicKey: v.name};

  /// Create key by seed phrase and save information about it in local store.
  /// Returns blockchain representation of key.
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

    await _hiveSource.addSeedOrRename(
      masterKey: key.publicKey,
      name: name ?? key.publicKey.ellipsePublicKey(),
    );

    await _savePassword(
      publicKey: key.publicKey,
      password: password,
    );

    _eventBus.fire(KeyAddedEvent(key));

    return key;
  }

  /// Create a sub(derived) key of [masterKey].
  /// Returns blockchain representation of key.
  Future<KeyStoreEntry> deriveKey({
    String? name,
    required String masterKey,
    required int accountId,
    required String password,
  }) async {
    final key = keys.firstWhere((e) => e.publicKey == masterKey);

    if (key.isLegacy || !key.isMaster) throw UnsupportedError('Key is not derivable');

    final createKeyInput = DerivedKeyCreateInput.derive(
      DerivedKeyCreateInputDerive(
        keyName: name,
        masterKey: masterKey,
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

    _eventBus.fire(KeyAddedEvent(derivedKey));

    return derivedKey;
  }

  /// Changes password of key by [publicKey] and returns update key. (local operation)
  /// If [oldPassword] is wrong - throws an exception.
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

  /// Change name of seed by [publicKey]. This affects [seedLabels] and mustn't be used for keys
  Future<void> renameSeed({
    required String publicKey,
    required String name,
  }) =>
      _hiveSource.addSeedOrRename(masterKey: publicKey, name: name);

  /// Change the label of key (local operation)
  /// This operation renames seed and change its instance inside [keys].
  Future<void> renameKey({
    required String publicKey,
    required String name,
  }) async {
    final key = keys.firstWhereOrNull((e) => e.publicKey == publicKey);

    if (key == null) return;

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

  /// Returns the seed phrase of [publicKey]
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

  /// Encrypt data for external usages
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

  /// Decrypt data from external usages.
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

  /// Sign [data] message with [publicKey]
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

  /// Sign [data] data with [publicKey]
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

  /// Sign [data] raw data with [publicKey]
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

  /// Check if password of [publicKey] equals to [password]
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

  /// Remove key and all derived keys from local store by [publicKey]
  Future<KeyStoreEntry> removeKey(String publicKey) async {
    final key = keys.firstWhere((e) => e.publicKey == publicKey);

    final keysForRemove = <KeyStoreEntry>[key];

    if (key.isNotLegacy && key.isMaster) {
      final derivedKeys = keys.where((e) => e.masterKey == publicKey);

      keysForRemove.addAll(keys.where((k) => derivedKeys.contains(k)));
    }

    for (final removedKey in keysForRemove) {
      await _keystore.removeKey(removedKey.publicKey);
      await _hiveSource.removeKeyPassword(removedKey.publicKey);

      _eventBus.fire(KeyRemovedEvent(removedKey));
    }

    if (key.isMaster) await _hiveSource.removeSeed(key.publicKey);

    await _updateCurrentKey();

    return key;
  }

  /// Clear all local data
  Future<void> clear() async {
    await _keystore.clear();

    await _hiveSource.clearSeeds();
    await _hiveSource.clearKeyPasswords();
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

  Future<void> _tryNamesMigration() async => _hiveSource.migrateSeedsNames(
        Map.fromEntries(keys.where((k) => k.isMaster).map((e) => MapEntry(e.publicKey, e.name))),
      );
}

extension KeysExtension on List<KeyStoreEntry> {
  List<KeyStoreEntry> whereKeysFor(String masterKey) => [
        firstWhere((e) => e.publicKey == masterKey),
        ...where((e) => e.masterKey == masterKey).toList(),
      ];

  /// Returns master key of [publicKey]
  KeyStoreEntry masterFor(String publicKey) {
    final thisKey = firstWhere((key) => key.publicKey == publicKey);
    if (thisKey.isMaster) return thisKey;
    return firstWhere((key) => key.publicKey == thisKey.masterKey);
  }
}
