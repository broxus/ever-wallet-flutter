import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/data/repositories/biometry_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

typedef PasswordAskAction<T> = void Function(T data);

class AuthUtils {
  AuthUtils._();

  /// Ask biometric(if possible) -> ask password (if biometric failed) -> do action
  static Future<void> askPasswordBeforeExport({
    required BuildContext context,
    required KeyStoreEntry seed,
    required PasswordAskAction<List<String>> goExport,
    required PasswordAskAction<KeyStoreEntry> enterPassword,
  }) async {
    final bioRepo = context.read<BiometryRepository>();
    final keysRepo = context.read<KeysRepository>();
    final isEnabled = bioRepo.status;
    final isAvailable = bioRepo.availability;

    if (isAvailable && isEnabled) {
      try {
        final password = await bioRepo.getKeyPassword(
          localizedReason: context.localization.authentication_reason,
          publicKey: seed.publicKey,
        );

        final phrase = await keysRepo.exportKey(
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
