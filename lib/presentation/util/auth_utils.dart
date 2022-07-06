import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../data/repositories/biometry_repository.dart';
import '../../data/repositories/keys_repository.dart';
import '../../injection.dart';
import '../../providers/biometry/biometry_availability_provider.dart';
import '../../providers/biometry/biometry_status_provider.dart';
import 'extensions/context_extensions.dart';

typedef PasswordAskAction<T> = void Function(T data);

class AuthUtils {
  AuthUtils._();

  /// Ask biometric(if possible) -> ask password (if biometric failed) -> do action
  static Future<void> askPasswordBeforeExport({
    required WidgetRef ref,
    required BuildContext context,
    required KeyStoreEntry seed,
    required PasswordAskAction<List<String>> goExport,
    required PasswordAskAction<KeyStoreEntry> enterPassword,
  }) async {
    final isEnabled = await ref.read(biometryStatusProvider.future);
    final isAvailable = await ref.read(biometryAvailabilityProvider.future);

    if (isAvailable && isEnabled) {
      try {
        final password = await getIt.get<BiometryRepository>().getKeyPassword(
              localizedReason: context.localization.authentication_reason,
              publicKey: seed.publicKey,
            );

        final phrase = await getIt.get<KeysRepository>().exportKey(
              publicKey: seed.publicKey,
              password: password,
            );

        goExport(phrase);
      } catch (err) {
        enterPassword(seed);
      }
    } else {
      enterPassword(seed);
    }
  }
}
