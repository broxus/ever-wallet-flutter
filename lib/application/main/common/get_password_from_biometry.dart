import 'package:ever_wallet/data/repositories/biometry_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<String?> getPasswordFromBiometry({
  required BuildContext context,
  required String publicKey,
}) async {
  final isEnabled = context.read<BiometryRepository>().status;
  final isAvailable = context.read<BiometryRepository>().availability;

  if (!isAvailable || !isEnabled) return null;

  try {
    return await context.read<BiometryRepository>().getKeyPassword(
          localizedReason: AppLocalizations.of(context)!.authentication_reason,
          publicKey: publicKey,
        );
  } catch (err) {
    return null;
  }
}
