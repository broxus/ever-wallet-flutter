import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../sources/local/storage_source.dart';

@preResolve
@lazySingleton
class KeystoreSource {
  late final Keystore keystore;
  final _keysSubject = BehaviorSubject<List<KeyStoreEntry>>.seeded([]);
  final _currentKeySubject = BehaviorSubject<KeyStoreEntry?>.seeded(null);

  KeystoreSource._();

  @factoryMethod
  static Future<KeystoreSource> create({
    required StorageSource storageSource,
  }) async {
    final instance = KeystoreSource._();
    await instance._initialize(
      storageSource: storageSource,
    );
    return instance;
  }

  Stream<List<KeyStoreEntry>> get keysStream => _keysSubject.distinct((a, b) => listEquals(a, b));

  List<KeyStoreEntry> get keys => _keysSubject.value;

  Stream<KeyStoreEntry?> get currentKeyStream => _currentKeySubject.distinct();

  KeyStoreEntry? get currentKey => _currentKeySubject.value;

  set currentKey(KeyStoreEntry? currentKey) => _currentKeySubject.add(currentKey);

  Future<KeyStoreEntry> addKey(CreateKeyInput createKeyInput) async {
    final key = await keystore.addKey(createKeyInput);

    _keysSubject.add(await keystore.entries);

    return key;
  }

  Future<KeyStoreEntry> updateKey(UpdateKeyInput updateKeyInput) async {
    final key = await keystore.updateKey(updateKeyInput);

    _keysSubject.add(await keystore.entries);

    return key;
  }

  Future<ExportKeyOutput> exportKey(ExportKeyInput exportKeyInput) => keystore.exportKey(exportKeyInput);

  Future<bool> checkKeyPassword(SignInput signInput) => keystore.checkKeyPassword(signInput);

  Future<KeyStoreEntry?> removeKey(String publicKey) async {
    final key = await keystore.removeKey(publicKey);

    _keysSubject.add(await keystore.entries);

    return key;
  }

  Future<void> clear() async {
    await keystore.clear();

    _keysSubject.add(await keystore.entries);
  }

  Future<void> _initialize({
    required StorageSource storageSource,
  }) async {
    keystore = await Keystore.create(storageSource.storage);

    _keysSubject.add(await keystore.entries);
  }
}
