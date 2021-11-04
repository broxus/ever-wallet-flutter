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
  final _availabilitySubject = BehaviorSubject<bool>.seeded(false);
  final _statusSubject = BehaviorSubject<bool>.seeded(false);

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
  Stream<bool> get biometryAvailabilityStream => _availabilitySubject.stream.distinct();

  @override
  bool get biometryAvailability => _availabilitySubject.value;

  @override
  Future<void> checkBiometryAvailability() async {
    final isAvailable = await _localAuthSource.getIsBiometryAvailable();
    _availabilitySubject.add(isAvailable);
  }

  @override
  Stream<bool> get biometryStatusStream => _statusSubject.stream.distinct();

  @override
  bool get biometryStatus => _statusSubject.value;

  @override
  Future<void> setBiometryStatus(bool isEnabled) async {
    await _hiveSource.setBiometryStatus(isEnabled);
    _statusSubject.add(isEnabled);
  }

  @override
  Future<void> setKeyPassword({
    required String publicKey,
    required String password,
  }) =>
      _hiveSource.setKeyPassword(
        publicKey: publicKey,
        password: password,
      );

  @override
  String? getKeyPassword(String publicKey) => _hiveSource.getKeyPassword(publicKey);

  @override
  Future<void> clear() async {
    await _hiveSource.clearKeysPasswords();
    await _hiveSource.clearUserPreferences();
  }

  @override
  Future<bool> authenticate(String localizedReason) => _localAuthSource.authenticate(localizedReason);

  Future<void> _initialize() async {
    _availabilitySubject.listen((value) async {
      if (!value) {
        _statusSubject.add(false);
      }
    });
    _statusSubject.listen((value) async {
      if (!value) {
        await _hiveSource.clearKeysPasswords();
      }
    });

    final isAvailable = await _localAuthSource.getIsBiometryAvailable();
    final isEnabled = _hiveSource.getBiometryStatus();

    _availabilitySubject.add(isAvailable);
    _statusSubject.add(isEnabled);
  }
}
