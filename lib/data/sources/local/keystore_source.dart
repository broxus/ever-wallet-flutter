import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../sources/local/storage_source.dart';

@preResolve
@lazySingleton
class KeystoreSource {
  late final Keystore _keystore;
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

  Future<KeyStoreEntry> addKey(CreateKeyInput input) async {
    final key = await _keystore.addKey(input);

    _keysSubject.add(await _keystore.keys);

    return key;
  }

  Future<List<KeyStoreEntry>> addKeys(List<CreateKeyInput> input) async {
    final keys = await _keystore.addKeys(input);

    _keysSubject.add(await _keystore.keys);

    return keys;
  }

  Future<KeyStoreEntry> updateKey(UpdateKeyInput input) async {
    final key = await _keystore.updateKey(input);

    _keysSubject.add(await _keystore.keys);

    return key;
  }

  Future<ExportKeyOutput> exportKey(ExportKeyInput input) => _keystore.exportKey(input);

  Future<List<EncryptedData>> encrypt({
    required String data,
    required List<String> publicKeys,
    required EncryptionAlgorithm algorithm,
    required SignInput input,
  }) =>
      _keystore.encrypt(
        data: data,
        publicKeys: publicKeys,
        algorithm: algorithm,
        input: input,
      );

  Future<String> decrypt({
    required EncryptedData data,
    required SignInput input,
  }) =>
      _keystore.decrypt(
        data: data,
        input: input,
      );

  Future<String> sign({
    required String data,
    required SignInput input,
  }) =>
      _keystore.sign(
        data: data,
        input: input,
      );

  Future<SignedData> signData({
    required String data,
    required SignInput input,
  }) =>
      _keystore.signData(
        data: data,
        input: input,
      );

  Future<SignedDataRaw> signDataRaw({
    required String data,
    required SignInput input,
  }) =>
      _keystore.signDataRaw(
        data: data,
        input: input,
      );

  Future<KeyStoreEntry?> removeKey(String publicKey) async {
    final key = await _keystore.removeKey(publicKey);

    _keysSubject.add(await _keystore.keys);

    return key;
  }

  Future<List<KeyStoreEntry>> removeKeys(List<String> publicKeys) async {
    final keys = await _keystore.removeKeys(publicKeys);

    _keysSubject.add(await _keystore.keys);

    return keys;
  }

  Future<void> clear() async {
    await _keystore.clear();

    _keysSubject.add(await _keystore.keys);
  }

  Future<void> reload() async {
    await _keystore.reload();

    _keysSubject.add(await _keystore.keys);
  }

  Future<bool> isPasswordCached({
    required String publicKey,
    required int duration,
  }) =>
      _keystore.isPasswordCached(
        publicKey: publicKey,
        duration: duration,
      );

  Future<void> _initialize({
    required StorageSource storageSource,
  }) async {
    _keystore = await Keystore.create(storageSource.storage);

    _keysSubject.add(await _keystore.keys);
  }
}
