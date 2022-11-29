import 'package:nekoton_flutter/nekoton_flutter.dart';

final kSeedSplitRegExp = RegExp('[ |;|,|:]');

const kDefaultWalletType = WalletType.everWallet();

const kDefaultMnemonicType = MnemonicType.labs(0);

const kDefaultWordsToCheckAmount = 3;
const kDefaultCheckAnswersAmount = 9;

const kTonDecimals = 9;

const kNonBreakingHyphen = '\u2011';

const kEverTicker = 'EVER';
const kVenomTicker = 'VENOM';

const kEverNetworkName = 'Everscale';
const kVenomNetworkName = 'Venom';
