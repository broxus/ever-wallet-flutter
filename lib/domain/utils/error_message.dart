import 'package:easy_localization/easy_localization.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../generated/codegen_loader.g.dart';

extension ExceptionX on Exception {
  String getMessage() {
    if (this is NativeException) {
      if (this is TonWalletException) {
        return LocaleKeys.error_message_ton_wallet.tr();
      } else if (this is KeyStoreException || this is CryptoException) {
        return LocaleKeys.error_message_password.tr();
      }
    }
    return LocaleKeys.error_message_unknown.tr();
  }
}
