import 'dart:async';

import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

import '../sources/local/hive_source.dart';
import 'keystore_repository.dart';

@preResolve
@lazySingleton
class CurrentKeyRepository {
  final KeystoreRepository _keystoreRepository;
  final HiveSource _hiveSource;
  final _currentKeySubject = BehaviorSubject<KeyStoreEntry?>.seeded(null);

  CurrentKeyRepository._(
    this._keystoreRepository,
    this._hiveSource,
  );

  @factoryMethod
  static Future<CurrentKeyRepository> create({
    required KeystoreRepository keystoreRepository,
    required HiveSource hiveSource,
  }) async {
    final currentKeyRepository = CurrentKeyRepository._(
      keystoreRepository,
      hiveSource,
    );
    await currentKeyRepository._initialize();
    return currentKeyRepository;
  }

  Stream<KeyStoreEntry?> get currentKeyStream => _currentKeySubject.stream;

  KeyStoreEntry? get currentKey => _currentKeySubject.value;

  Future<void> setCurrentKey(KeyStoreEntry? currentKey) async {
    await _hiveSource.setCurrentPublicKey(currentKey?.publicKey);

    _currentKeySubject.add(currentKey);
  }

  Future<void> _initialize() async {
    final currentPublicKey = _hiveSource.getCurrentPublicKey();

    final currentKey = _keystoreRepository.keys.firstWhereOrNull((e) => e.publicKey == currentPublicKey);

    if (currentKey != null) {
      _currentKeySubject.add(currentKey);
    } else {
      await setCurrentKey(_keystoreRepository.keys.firstOrNull);
    }

    final lock = Lock();
    _keystoreRepository.keysStream.listen(
      (event) async => lock.synchronized(() async {
        if (this.currentKey == null || !event.contains(this.currentKey)) {
          await setCurrentKey(_keystoreRepository.keys.firstOrNull);
        }
      }),
    );
  }
}
