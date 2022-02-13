import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:rxdart/subjects.dart';

import '../sources/local/hive_source.dart';
import '../sources/local/local_auth_source.dart';

@preResolve
@lazySingleton
class BiometryRepository {
  final HiveSource _hiveSource;
  final LocalAuthSource _localAuthSource;
  final _availabilitySubject = BehaviorSubject<bool>();
  final _statusSubject = BehaviorSubject<bool>();

  BiometryRepository._(
    this._hiveSource,
    this._localAuthSource,
  );

  @factoryMethod
  static Future<BiometryRepository> create({
    required HiveSource hiveSource,
    required LocalAuthSource localAuthSource,
  }) async {
    final biometryRepositoryImpl = BiometryRepository._(
      hiveSource,
      localAuthSource,
    );
    await biometryRepositoryImpl._initialize();
    return biometryRepositoryImpl;
  }

  Stream<bool> get biometryAvailabilityStream => _availabilitySubject.stream;

  bool get biometryAvailability => _availabilitySubject.value;

  Future<void> checkBiometryAvailability() async {
    final isAvailable = await _localAuthSource.getIsBiometryAvailable();
    _availabilitySubject.add(isAvailable);
  }

  Stream<bool> get biometryStatusStream => _statusSubject.stream;

  bool get biometryStatus => _statusSubject.value;

  Future<void> setBiometryStatus({
    required String localizedReason,
    required bool isEnabled,
  }) async {
    final isAuthenticated = await authenticate(localizedReason);

    if (isAuthenticated) {
      await _hiveSource.setBiometryStatus(isEnabled);
      _statusSubject.add(isEnabled);
    }
  }

  Future<void> clear() async {
    await _hiveSource.clearKeysPasswords();
    await _hiveSource.clearUserPreferences();
  }

  Future<bool> authenticate(String localizedReason) => _localAuthSource.authenticate(localizedReason);

  Future<void> setKeyPassword({
    required String publicKey,
    required String password,
  }) =>
      _hiveSource.setKeyPassword(
        publicKey: publicKey,
        password: password,
      );

  Future<String> getKeyPassword({
    required String localizedReason,
    required String publicKey,
  }) async {
    final password = _hiveSource.getKeyPassword(publicKey);

    if (password != null) {
      final isAuthenticated = await authenticate(localizedReason);

      if (isAuthenticated) {
        return password;
      } else {
        throw Exception('Is not authenticated');
      }
    } else {
      throw Exception('Password is not stored');
    }
  }

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
