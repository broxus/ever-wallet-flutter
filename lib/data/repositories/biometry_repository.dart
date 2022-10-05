import 'dart:async';

import 'package:ever_wallet/data/sources/local/app_lifecycle_state_source.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:local_auth/local_auth.dart';
import 'package:rxdart/subjects.dart';

class BiometryRepository {
  final HiveSource _hiveSource;
  final AppLifecycleStateSource _appLifecycleStateSource;
  final _availabilitySubject = BehaviorSubject<bool>();
  final _localAuth = LocalAuthentication();
  late final StreamSubscription _appLifecycleStateStreamSubscription;
  late final StreamSubscription _availabilityStreamSubscription;
  late final StreamSubscription _statusStreamSubscription;

  BiometryRepository._({
    required HiveSource hiveSource,
    required AppLifecycleStateSource appLifecycleStateSource,
  })  : _hiveSource = hiveSource,
        _appLifecycleStateSource = appLifecycleStateSource;

  static Future<BiometryRepository> create({
    required HiveSource hiveSource,
    required AppLifecycleStateSource appLifecycleStateSource,
  }) async {
    final instance = BiometryRepository._(
      hiveSource: hiveSource,
      appLifecycleStateSource: appLifecycleStateSource,
    );
    await instance._initialize();
    return instance;
  }

  Stream<bool> get availabilityStream => _availabilitySubject;

  bool get availability => _availabilitySubject.value;

  Stream<bool> get statusStream => _hiveSource.isBiometryEnabledStream;

  bool get status => _hiveSource.isBiometryEnabled;

  Future<void> setStatus({
    required String localizedReason,
    required bool isEnabled,
  }) async {
    if (isEnabled && !await _authenticate(localizedReason)) return;

    await _hiveSource.setIsBiometryEnabled(isEnabled);
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
    if (!await _localAuth.canCheckBiometrics) return false;
    if (!await _localAuth.isDeviceSupported()) return false;
    if (await _localAuth.getAvailableBiometrics().then((v) => v.isEmpty)) return false;
    return true;
  }

  Future<void> clear() async {
    await _hiveSource.clearKeyPasswords();
    await _hiveSource.clearIsBiometryEnabled();
  }

  Future<void> dispose() async {
    await _appLifecycleStateStreamSubscription.cancel();
    await _availabilityStreamSubscription.cancel();
    await _statusStreamSubscription.cancel();

    await _availabilitySubject.close();
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

    _appLifecycleStateStreamSubscription = _appLifecycleStateSource.appLifecycleStateStream
        .asyncMap((_) => _isAvailable)
        .listen((e) => _availabilitySubject.add(e));

    _availabilityStreamSubscription =
        availabilityStream.where((e) => !e).listen((e) => _hiveSource.setIsBiometryEnabled(e));

    _statusStreamSubscription =
        statusStream.where((e) => !e).listen((e) => _hiveSource.clearKeyPasswords());
  }
}
