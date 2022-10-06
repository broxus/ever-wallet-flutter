import 'package:nekoton_flutter/nekoton_flutter.dart';

extension TokenWalletVersionX on TokenWalletVersion {
  int toInt() {
    switch (this) {
      case TokenWalletVersion.oldTip3v4:
        return 4;
      case TokenWalletVersion.tip3:
        return 5;
      default:
        throw Exception('Invalid token wallet version');
    }
  }
}

extension IntX on int {
  TokenWalletVersion toTokenWalletVersion() {
    switch (this) {
      case 4:
        return TokenWalletVersion.oldTip3v4;
      case 5:
        return TokenWalletVersion.tip3;
      default:
        throw Exception('Invalid token wallet version');
    }
  }
}

extension WalletTypeX on WalletType {
  int toInt() => when(
        walletV3: () => 3,
        multisig: (multisigType) {
          switch (multisigType) {
            case MultisigType.safeMultisigWallet:
              return 4;
            case MultisigType.safeMultisigWallet24h:
              return 5;
            case MultisigType.setcodeMultisigWallet:
              return 6;
            case MultisigType.setcodeMultisigWallet24h:
              return 7;
            case MultisigType.bridgeMultisigWallet:
              return 8;
            case MultisigType.surfWallet:
              return 9;
            case MultisigType.multisig2:
              return 2;
          }
        },
        highloadWalletV2: () => 10,
        everWallet: () => 1,
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
            case MultisigType.multisig2:
              return 'Multisig';
          }
        },
        walletV3: () => 'WalletV3',
        highloadWalletV2: () => 'HighloadWalletV2',
        everWallet: () => 'EverWallet',
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
  Future<T> asyncFirstWhere(Future<bool> Function(T element) test, {T Function()? orElse}) async {
    for (final element in this) {
      if (await test(element)) return element;
    }
    if (orElse != null) return orElse();
    throw StateError('No element');
  }

  Future<T?> asyncFirstWhereOrNull(Future<bool> Function(T element) test) async {
    for (final element in this) {
      if (await test(element)) return element;
    }
    return null;
  }

  Future<Iterable<K>> asyncMap<K>(Future<K> Function(T element) toElement) =>
      Future.wait<K>(map((e) => toElement(e)));

  Future<Iterable<T>> asyncWhere(Future<bool> Function(T element) test) async => <T>[
        for (final element in this)
          if (await test(element)) element,
      ];

  Future<bool> asyncAny(Future<bool> Function(T element) test) async {
    for (final element in this) {
      if (await test(element)) return true;
    }
    return false;
  }

  Future<bool> asyncEvery(Future<bool> Function(T element) test) async {
    for (final element in this) {
      if (!(await test(element))) return false;
    }
    return true;
  }
}

extension ExceptionX on Exception {
  String toUiMessage() => toString().replaceAllMapped('Exception: ', (match) => '');
}
