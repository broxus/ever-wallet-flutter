import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:rxdart/subjects.dart';

import '../../domain/repositories/biometry_repository.dart';
import '../sources/local/hive_source.dart';
import '../sources/local/local_auth_source.dart';

@preResolve
@LazySingleton(as: BiometryRepository)
class BiometryRepositoryImpl implements BiometryRepository {
  final HiveSource _hiveSource;
  final LocalAuthSource _localAuthSource;
  final _biometryAvailabilitySubject = BehaviorSubject<bool>();
  final _biometryStatusSubject = BehaviorSubject<bool>();

  BiometryRepositoryImpl._(
    this._hiveSource,
    this._localAuthSource,
  );

  @factoryMethod
  static Future<BiometryRepositoryImpl> create(
    HiveSource hiveSource,
    LocalAuthSource localAuthSource,
  ) async {
    final biometryRepositoryImpl = BiometryRepositoryImpl._(
      hiveSource,
      localAuthSource,
    );
    await biometryRepositoryImpl._initialize();
    return biometryRepositoryImpl;
  }

  @override
  bool get biometryAvailability => _biometryAvailabilitySubject.value;

  @override
  Stream<bool> get biometryAvailabilityStream => _biometryAvailabilitySubject.stream;

  @override
  Future<void> checkBiometryAvailability() async {
    final isAvailable = await _localAuthSource.isBiometryAvailable;
    _biometryAvailabilitySubject.add(isAvailable);
  }

  @override
  bool get biometryStatus => _biometryStatusSubject.value;

  @override
  Stream<bool> get biometryStatusStream => _biometryStatusSubject.stream;

  @override
  Future<void> setBiometryStatus({required bool isEnabled}) async {
    await _hiveSource.setBiometryStatus(isEnabled: isEnabled);
    _biometryStatusSubject.add(isEnabled);
  }

  @override
  Future<void> setKeyPassword({
    required String publicKey,
    required String password,
  }) async =>
      _hiveSource.setKeyPassword(
        publicKey: publicKey,
        password: password,
      );

  @override
  Future<String?> getKeyPassword(String publicKey) async => _hiveSource.getKeyPassword(publicKey);

  @override
  Future<void> clear() async {
    await _hiveSource.clearPasswords();
    await _hiveSource.clearBiometryPreferences();
  }

  @override
  Future<bool> authenticate(String localizedReason) async => _localAuthSource.authenticate(localizedReason);

  Future<void> _initialize() async {
    _biometryAvailabilitySubject.listen((value) async {
      if (!value) {
        _biometryStatusSubject.add(false);
      }
    });
    _biometryStatusSubject.listen((value) async {
      if (!value) {
        await _hiveSource.clearPasswords();
      }
    });

    final isBiometryAvailable = await _localAuthSource.isBiometryAvailable;
    final isBiometryEnabled = await _hiveSource.biometryStatus;

    _biometryAvailabilitySubject.add(isBiometryAvailable);
    _biometryStatusSubject.add(isBiometryEnabled);
  }
}
