import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../data/repositories/biometry_repository.dart';
import '../../../../../../injection.dart';

Future<String?> getPasswordFromBiometry({
  required BuildContext context,
  required String publicKey,
}) async {
  final isEnabled = getIt.get<BiometryRepository>().status;
  final isAvailable = getIt.get<BiometryRepository>().availability;

  if (!isAvailable || !isEnabled) return null;

  try {
    return await getIt.get<BiometryRepository>().getKeyPassword(
          localizedReason: AppLocalizations.of(context)!.authentication_reason,
          publicKey: publicKey,
        );
  } catch (err) {
    return null;
  }
}
