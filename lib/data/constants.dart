import 'package:nekoton_flutter/nekoton_flutter.dart';

const kIntensivePollingInterval = Duration(seconds: 2);

const kNextBlockTimeout = Duration(seconds: 60);

const kSubscriptionRefreshTimeout = Duration(seconds: 10);

const kCurrenciesRefreshTimeout = Duration(seconds: 60);

const kAddressForEverCurrency =
    '0:a49cd4e158a9a15555e624759e2e4e766d22600b7800d891e46f9291f044a93d';

const kDefaultWorkchain = 0;

const kMessageBounce = false;

const kDefaultMessageExpiration = Expiration.timeout(kDefaultMessageTimeout);

const kDefaultMessageTimeout = 60;

const kAvailableWallets = [
  WalletType.multisig(MultisigType.safeMultisigWallet),
  WalletType.multisig(MultisigType.safeMultisigWallet24h),
  WalletType.multisig(MultisigType.setcodeMultisigWallet),
  WalletType.multisig(MultisigType.setcodeMultisigWallet24h),
  WalletType.multisig(MultisigType.bridgeMultisigWallet),
  WalletType.multisig(MultisigType.surfWallet),
  WalletType.walletV3(),
];
