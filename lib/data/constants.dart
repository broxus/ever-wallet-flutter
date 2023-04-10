import 'package:nekoton_flutter/nekoton_flutter.dart';

const maxLastSelectedSeeds = 4;

const kIntensivePollingInterval = Duration(seconds: 2);

const kNextBlockTimeout = Duration(seconds: 60);

const kSubscriptionRefreshTimeout = Duration(seconds: 10);

const kCurrenciesRefreshTimeout = Duration(seconds: 60);

const kAddressForEverCurrency =
    '0:a49cd4e158a9a15555e624759e2e4e766d22600b7800d891e46f9291f044a93d';

const kAddressForVenomCurrency =
    '0:28237a5d5abb32413a79b5f98573074d3b39b72121305d9c9c97912fc06d843c';

const kDefaultWorkchain = 0;

const kMessageBounce = false;

const kDefaultMessageExpiration = Expiration.timeout(kDefaultMessageTimeout);

const kDefaultMessageTimeout = 60;

const kEverAvailableWallets = [
  WalletType.everWallet(),
  WalletType.multisig(MultisigType.multisig2),
  WalletType.multisig(MultisigType.multisig2_1),
  WalletType.walletV3(),
  WalletType.multisig(MultisigType.safeMultisigWallet),
  WalletType.multisig(MultisigType.safeMultisigWallet24h),
  WalletType.multisig(MultisigType.setcodeMultisigWallet),
  WalletType.multisig(MultisigType.setcodeMultisigWallet24h),
  WalletType.multisig(MultisigType.bridgeMultisigWallet),
  WalletType.multisig(MultisigType.surfWallet),
];

const kVenomAvailableWallets = [
  WalletType.everWallet(),
  WalletType.multisig(MultisigType.multisig2_1),
];
