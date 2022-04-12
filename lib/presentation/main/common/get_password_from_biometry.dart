import 'package:easy_localization/easy_localization.dart';

import '../../../../../../data/repositories/biometry_repository.dart';
import '../../../../../../injection.dart';
import '../../../generated/codegen_loader.g.dart';

Future<String?> getPasswordFromBiometry(String publicKey) async {
  final isEnabled = getIt.get<BiometryRepository>().status;
  final isAvailable = getIt.get<BiometryRepository>().availability;

  if (!isAvailable || !isEnabled) return null;

  try {
    return await getIt.get<BiometryRepository>().getKeyPassword(
          localizedReason: LocaleKeys.authentication_reason.tr(),
          publicKey: publicKey,
        );
  } catch (err) {
    return null;
  }
}
