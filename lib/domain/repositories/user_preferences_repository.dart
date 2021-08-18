abstract class UserPreferencesRepository {
  Future<String?> get currentPublicKey;

  Future<void> setCurrentPublicKey(String? currentPublicKey);

  Future<void> clear();
}
