import 'dart:async';

import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

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
        everWallet: () => 0,
        walletV3: () => 1,
        multisig: (multisigType) {
          switch (multisigType) {
            case MultisigType.safeMultisigWallet:
              return 2;
            case MultisigType.safeMultisigWallet24h:
              return 3;
            case MultisigType.setcodeMultisigWallet:
              return 4;
            case MultisigType.setcodeMultisigWallet24h:
              return 5;
            case MultisigType.bridgeMultisigWallet:
              return 6;
            case MultisigType.surfWallet:
              return 7;
            case MultisigType.multisig2:
              return 8;
            case MultisigType.multisig2_1:
              return 9;
          }
        },
        highloadWalletV2: () => 10,
      );

  String get name => when(
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
              return 'Multisig2';
            case MultisigType.multisig2_1:
              return 'Multisig2.1';
          }
        },
        everWallet: () => 'EverWallet',
        walletV3: () => 'WalletV3',
        highloadWalletV2: () => 'HighloadWalletV2',
      );

  String description(BuildContext context) {
    final localization = context.localization;

    return when(
      multisig: (multisigType) {
        switch (multisigType) {
          case MultisigType.safeMultisigWallet:
            return localization.safeMultisigDescription;
          case MultisigType.safeMultisigWallet24h:
            return localization.safeMultisig24Description;
          case MultisigType.setcodeMultisigWallet:
            return localization.setcodeMultisigDescription;
          case MultisigType.setcodeMultisigWallet24h:
            return localization.setcodeMultisig24Description;
          case MultisigType.bridgeMultisigWallet:
            return localization.bridgeMultisigDescription;
          case MultisigType.surfWallet:
            return localization.surfDescription;
          case MultisigType.multisig2:
            return localization.multisig2Description;
          case MultisigType.multisig2_1:
            return localization.multisig2_1_Description;
        }
      },
      everWallet: () => localization.everWalletDescription,
      walletV3: () => localization.walletV3Description,
      highloadWalletV2: () => localization.highloadWalletDescription,
    );
  }
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
            PasswordExplicit(
              password: password,
              cacheBehavior: const PasswordCacheBehavior.nop(),
            ),
          ),
        )
      : DerivedKeySignParams.byAccountId(
          DerivedKeySignParamsByAccountId(
            masterKey: masterKey,
            accountId: accountId,
            password: Password.explicit(
              PasswordExplicit(
                password: password,
                cacheBehavior: const PasswordCacheBehavior.nop(),
              ),
            ),
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
  Future<Iterable<K>> asyncMap<K>(Future<K> Function(T element) toElement) =>
      Future.wait<K>(map((e) => toElement(e)));
}

extension ExceptionX on Exception {
  String toUiMessage() => toString().replaceAllMapped('Exception: ', (match) => '');
}

extension SubjectX<T> on Subject<T> {
  void tryAdd(T event) {
    if (!isClosed) add(event);
  }
}

extension ExpireAtToTimeout on int {
  Duration toTimeout() =>
      DateTime.fromMillisecondsSinceEpoch(this * 1000).difference(DateTime.now());
}

extension FutureX<T> on Future<T> {
  Completer<T> wrapInCompleter() {
    final completer = Completer<T>();

    then(completer.complete).catchError(completer.completeError);

    return completer;
  }
}

extension SecondsSinceEpoch on DateTime {
  int get secondsSinceEpoch =>
      DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
}

extension TransportX on Transport {
  /// List of items that can be used to compare transport objects
  List<dynamic> toEquatableCollection() => [name, networkId, group];
}
