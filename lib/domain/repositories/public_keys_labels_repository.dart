import 'dart:async';

abstract class PublicKeysLabelsRepository {
  Stream<Map<String, String>> get labelsStream;

  Future<void> save({
    required String publicKey,
    required String label,
  });

  Future<void> remove(String publicKey);

  Future<void> clear();
}
