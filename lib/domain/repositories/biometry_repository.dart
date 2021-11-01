abstract class BiometryRepository {
  Stream<bool> get biometryAvailabilityStream;

  bool get biometryAvailability;

  Future<void> checkBiometryAvailability();

  Stream<bool> get biometryStatusStream;

  bool get biometryStatus;

  Future<void> setBiometryStatus(bool isEnabled);

  Future<void> setKeyPassword({
    required String publicKey,
    required String password,
  });

  String? getKeyPassword(String publicKey);

  Future<void> clear();

  Future<bool> authenticate(String localizedReason);
}
