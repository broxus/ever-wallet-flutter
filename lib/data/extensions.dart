import 'package:nekoton_flutter/nekoton_flutter.dart';

extension TokenWalletVersionX on TokenWalletVersion {
  int toInt() {
    switch (this) {
      case TokenWalletVersion.oldTip3v4:
        return 4;
      case TokenWalletVersion.tip3:
        return 5;
    }
  }
}

TokenWalletVersion tokenWalletVersionFromInt(int version) {
  switch (version) {
    case 4:
      return TokenWalletVersion.oldTip3v4;
    case 5:
      return TokenWalletVersion.tip3;
    default:
      throw Exception('Invalid token wallet version');
  }
}

extension WalletTypeX on WalletType {
  int toInt() => when(
        multisig: (multisigType) {
          switch (multisigType) {
            case MultisigType.safeMultisigWallet:
              return 1;
            case MultisigType.safeMultisigWallet24h:
              return 2;
            case MultisigType.setcodeMultisigWallet:
              return 3;
            case MultisigType.setcodeMultisigWallet24h:
              return 4;
            case MultisigType.bridgeMultisigWallet:
              return 5;
            case MultisigType.surfWallet:
              return 6;
          }
        },
        walletV3: () => 7,
      );

  String describe() => when(
        multisig: (multisigType) {
          switch (multisigType) {
            case MultisigType.safeMultisigWallet:
              return 'SafeMultisig';
            case MultisigType.safeMultisigWallet24h:
              return 'SafeMultisig24';
            case MultisigType.setcodeMultisigWallet:
              return 'SetcodeMultisig';
            case MultisigType.setcodeMultisigWallet24h:
              return 'SetcodeMultisig24';
            case MultisigType.bridgeMultisigWallet:
              return 'BridgeMultisig';
            case MultisigType.surfWallet:
              return 'Surf';
          }
        },
        walletV3: () => 'WalletV3',
      );
}

extension ExistingWalletInfoX on ExistingWalletInfo {
  bool get isActive {
    final isDeployed = contractState.isDeployed;
    final balanceIsGreaterThanZero = BigInt.parse(contractState.balance) > BigInt.zero;

    return isDeployed || balanceIsGreaterThanZero;
  }
}

extension KeyStoreEntryX on KeyStoreEntry {
  SignInput signInput(String password) => isLegacy
      ? EncryptedKeyPassword(
          publicKey: publicKey,
          password: Password.explicit(
            password: password,
            cacheBehavior: const PasswordCacheBehavior.remove(),
          ),
        )
      : DerivedKeySignParams.byAccountId(
          masterKey: masterKey,
          accountId: accountId,
          password: Password.explicit(
            password: password,
            cacheBehavior: const PasswordCacheBehavior.remove(),
          ),
        );
}

extension StringX on String {
  int toInt() {
    final parts = split('.');

    if (parts.length != 3) throw Exception('Invalid version format');

    for (final part in parts) {
      if (int.parse(part) > 999) throw Exception('Invalid version format');
    }

    int multiplier = 1000000;
    int numericVersion = 0;

    for (var i = 0; i < 3; i++) {
      numericVersion += int.parse(parts[i]) * multiplier;
      multiplier = multiplier ~/ 1000;
    }

    <int>[].map((e) => null);

    return numericVersion;
  }
}

extension IterableX<T> on Iterable<T> {
  Future<T?> asyncFirstWhereOrNull(Future<bool> Function(T element) test) async {
    for (final element in this) {
      if (await test(element)) return element;
    }
    return null;
  }

  Future<Iterable<K>> asyncMap<K>(Future<K> Function(T e) toElement) => Future.wait<K>(map((e) => toElement(e)));
}
