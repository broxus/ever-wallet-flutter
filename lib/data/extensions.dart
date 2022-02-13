import 'package:nekoton_flutter/nekoton_flutter.dart';

extension ManifestTokenWalletVersion on TokenWalletVersion {
  int toManifest() {
    switch (this) {
      case TokenWalletVersion.oldTip3v4:
        return 4;
      case TokenWalletVersion.tip3:
        return 5;
    }
  }
}

TokenWalletVersion tokenWalletVersionFromManifest(int version) {
  if (version <= 4) {
    return TokenWalletVersion.oldTip3v4;
  } else {
    return TokenWalletVersion.tip3;
  }
}
