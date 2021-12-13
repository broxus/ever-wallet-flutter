import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:rxdart/subjects.dart';

import '../sources/local/hive_source.dart';
import '../sources/local/local_auth_source.dart';

@preResolve
@lazySingleton
class PublicKeysLabelsRepository {
  final HiveSource _hiveSource;
  final _labelsSubject = BehaviorSubject<Map<String, String>>();

  PublicKeysLabelsRepository._(this._hiveSource);

  @factoryMethod
  static Future<PublicKeysLabelsRepository> create(
    HiveSource hiveSource,
    LocalAuthSource localAuthSource,
  ) async {
    final biometryRepositoryImpl = PublicKeysLabelsRepository._(hiveSource);
    await biometryRepositoryImpl._initialize();
    return biometryRepositoryImpl;
  }

  Stream<Map<String, String>> get labelsStream => _labelsSubject.stream;

  Future<void> save({
    required String publicKey,
    required String label,
  }) async {
    await _hiveSource.setPublicKeyLabel(
      publicKey: publicKey,
      label: label,
    );
    _labelsSubject.add(_hiveSource.getPublicKeysLabels());
  }

  Future<void> remove(String publicKey) async {
    await _hiveSource.removePublicKeyLabel(publicKey);
    _labelsSubject.add(_hiveSource.getPublicKeysLabels());
  }

  Future<void> clear() async {
    await _hiveSource.clearPublicKeysLabels();
    _labelsSubject.add(_hiveSource.getPublicKeysLabels());
  }

  Future<void> _initialize() async {
    _labelsSubject.add(_hiveSource.getPublicKeysLabels());
  }
}
