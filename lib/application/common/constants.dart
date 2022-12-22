import 'package:nekoton_flutter/nekoton_flutter.dart';

final kSeedSplitRegExp = RegExp(r'[ |;|,|:|\n|.]');

/// This wallet types depends on kEverAvailableWallets and kVenomAvailableWallets
const kDefaultEverWalletType = WalletType.everWallet();
const kDefaultVenomWalletType = WalletType.walletV3();

WalletType getDefaultWalletType(bool isEver) =>
    isEver ? kDefaultEverWalletType : kDefaultVenomWalletType;

const kDefaultMnemonicType = MnemonicType.labs(0);

const kDefaultWordsToCheckAmount = 3;
const kDefaultCheckAnswersAmount = 9;

const kTonDecimals = 9;

const kNonBreakingHyphen = '\u2011';

const kEverTicker = 'EVER';
const kVenomTicker = 'VENOM';

const kEverNetworkName = 'Everscale';
const kVenomNetworkName = 'Venom';
