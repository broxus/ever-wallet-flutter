import '../../../../../../data/repositories/biometry_repository.dart';
import '../../../../../../injection.dart';

Future<String?> getPasswordFromBiometry(String publicKey) async {
  final isEnabled = getIt.get<BiometryRepository>().status;
  final isAvailable = getIt.get<BiometryRepository>().availability;

  if (!isAvailable || !isEnabled) return null;

  try {
    return await getIt.get<BiometryRepository>().getKeyPassword(
          localizedReason: 'Please authenticate to interact with wallet',
          publicKey: publicKey,
        );
  } catch (err) {
    return null;
  }
}
