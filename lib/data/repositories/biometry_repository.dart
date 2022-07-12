import 'dart:async';

import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:local_auth/local_auth.dart';
import 'package:rxdart/subjects.dart';

class BiometryRepository {
  final HiveSource _hiveSource;
  final _localAuth = LocalAuthentication();
  final _availabilitySubject = BehaviorSubject<bool>();
  final _statusSubject = BehaviorSubject<bool>();
  late final StreamSubscription _availabilityStreamSubscription;
  late final StreamSubscription _statusStreamSubscription;

  BiometryRepository._(this._hiveSource);

  static Future<BiometryRepository> create(HiveSource hiveSource) async {
    final instance = BiometryRepository._(hiveSource);
    await instance._initialize();
    return instance;
  }

  Stream<bool> get availabilityStream => _availabilitySubject.distinct();

  bool get availability => _availabilitySubject.value;

  Stream<bool> get statusStream => _statusSubject.distinct();

  bool get status => _statusSubject.value;

  Future<void> checkAvailability() async => _availabilitySubject.add(await _isAvailable);

  Future<void> setStatus({
    required String localizedReason,
    required bool isEnabled,
  }) async {
    if (isEnabled && !await _authenticate(localizedReason)) return;

    await _hiveSource.setIsBiometryEnabled(isEnabled: isEnabled);

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
      if (await _authenticate(localizedReason)) {
        return password;
      } else {
        throw Exception('Is not authenticated');
      }
    } else {
      throw Exception('Password is not stored');
    }
  }

  Future<bool> get _isAvailable async {
    final isAvailable = await _localAuth.canCheckBiometrics;
    final isDeviceSupported = await _localAuth.isDeviceSupported();
    return isAvailable && isDeviceSupported;
  }

  Future<void> clear() async {
    await _hiveSource.clearKeysPasswords();
    await _hiveSource.clearUserPreferences();
  }

  Future<void> dispose() async {
    await _availabilityStreamSubscription.cancel();
    await _statusStreamSubscription.cancel();

    await _availabilitySubject.close();
    await _statusSubject.close();
  }

  Future<bool> _authenticate(String localizedReason) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );
    } catch (_) {
      _availabilitySubject.add(await _isAvailable);
      rethrow;
    }
  }

  Future<void> _initialize() async {
    _availabilitySubject.add(await _isAvailable);
    _statusSubject.add(_hiveSource.isBiometryEnabled);

    _availabilityStreamSubscription =
        availabilityStream.where((e) => !e).listen((e) => _statusSubject.add(e));
    _statusStreamSubscription =
        statusStream.where((e) => !e).listen((e) => _hiveSource.clearKeysPasswords());
  }
}
