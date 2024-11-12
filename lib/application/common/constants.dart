import 'package:ever_wallet/data/models/network_type.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

final kSeedSplitRegExp = RegExp(r'[ |;|,|:|\n|.]');

/// This wallet types depends on kEverAvailableWallets and kVenomAvailableWallets
const kDefaultEverWalletType = WalletType.everWallet();
const kDefaultVenomWalletType = WalletType.everWallet();
const kDefaultTychoWalletType = WalletType.everWallet();

WalletType getDefaultWalletType(NetworkType type) => type.when(
      everscale: () => kDefaultEverWalletType,
      venom: () => kDefaultVenomWalletType,
      tycho: () => kDefaultTychoWalletType,
    );

const kDefaultMnemonicType = MnemonicType.labs(0);

const kDefaultWordsToCheckAmount = 3;
const kDefaultCheckAnswersAmount = 9;

const kTonDecimals = 9;

const kNonBreakingHyphen = '\u2011';

const kEverTicker = 'EVER';
const kStEverTicker = 'stEVER';
const kVenomTicker = 'VENOM';

const kEverNetworkName = 'Everscale';
const kVenomNetworkName = 'Venom';
const kTychoNetworkName = 'Tycho';

const kBroxusSupportLink = 'https://t.me/broxus_chat';
