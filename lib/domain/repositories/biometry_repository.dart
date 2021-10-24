abstract class BiometryRepository {
  bool get biometryAvailability;

  Stream<bool> get biometryAvailabilityStream;

  Future<void> checkBiometryAvailability();

  bool get biometryStatus;

  Stream<bool> get biometryStatusStream;

  Future<void> setBiometryStatus({required bool isEnabled});

  Future<void> setKeyPassword({
    required String publicKey,
    required String password,
  });

  Future<String?> get(String publicKey);

  Future<void> clear();

  Future<bool> authenticate(String localizedReason);
}
