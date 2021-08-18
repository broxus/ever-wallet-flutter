import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';

@lazySingleton
class LocalAuthSource {
  final _localAuth = LocalAuthentication();

  Future<bool> get isBiometryAvailable async {
    final isSupported = await _localAuth.isDeviceSupported();

    if (!isSupported) {
      return false;
    }

    final available = await _localAuth.getAvailableBiometrics();

    return available.isNotEmpty;
  }

  Future<bool> authenticate(String localizedReason) => _localAuth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: true,
      );
}
