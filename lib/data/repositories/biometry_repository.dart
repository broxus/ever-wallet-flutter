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
    final instance = BiometryRepository._(
      hiveSource,
      localAuthSource,
    );
    await instance._initialize();
    return instance;
  }

  Stream<bool> get biometryAvailabilityStream => _availabilitySubject;

  bool get biometryAvailability => _availabilitySubject.value;

  Stream<bool> get biometryStatusStream => _statusSubject;

  bool get biometryStatus => _statusSubject.value;

  Future<void> checkBiometryAvailability() async => _availabilitySubject.add(await _localAuthSource.isAvailable);

  Future<void> setBiometryStatus({
    required String localizedReason,
    required bool isEnabled,
  }) async {
    if (isEnabled && !await _localAuthSource.authenticate(localizedReason)) return;

    await _hiveSource.setIsBiometryEnabled(isEnabled);

    _statusSubject.add(isEnabled);
  }

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
      if (await _localAuthSource.authenticate(localizedReason)) {
        return password;
      } else {
        throw Exception('Is not authenticated');
      }
    } else {
      throw Exception('Password is not stored');
    }
  }

  Future<void> clear() async {
    await _hiveSource.clearKeysPasswords();
    await _hiveSource.clearUserPreferences();
  }

  Future<void> _initialize() async {
    _availabilitySubject.add(await _localAuthSource.isAvailable);
    _statusSubject.add(_hiveSource.isBiometryEnabled);

    _availabilitySubject.where((e) => !e).listen((e) => _statusSubject.add(e));
    _statusSubject.where((e) => !e).listen((e) => _hiveSource.clearKeysPasswords());
  }
}
