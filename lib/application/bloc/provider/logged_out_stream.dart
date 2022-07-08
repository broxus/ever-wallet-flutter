import 'package:ever_wallet/data/repositories/keys_repository.dart';

Stream<void> loggedOutStream(KeysRepository keysRepository) =>
    keysRepository.keysStream.where((e) => e.isEmpty);
