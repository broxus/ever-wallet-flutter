import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';

@lazySingleton
class LocalAuthSource {
  final _localAuth = LocalAuthentication();

  Future<bool> getIsBiometryAvailable() async {
    if (!await _localAuth.canCheckBiometrics || !await _localAuth.isDeviceSupported()) {
      return false;
    }

    final available = await _localAuth.getAvailableBiometrics();

    return available.contains(BiometricType.fingerprint) || available.contains(BiometricType.face);
  }

  Future<bool> authenticate(String localizedReason) async {
    if (await getIsBiometryAvailable()) {
      return _localAuth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: true,
      );
    } else {
      throw Exception();
    }
  }
}
