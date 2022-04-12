import 'package:nekoton_flutter/nekoton_flutter.dart';

const kSubscriptionRefreshTimeout = Duration(seconds: 10);

const kCurrenciesRefreshTimeout = Duration(seconds: 60);

const kAddressForEverCurrency = '0:a49cd4e158a9a15555e624759e2e4e766d22600b7800d891e46f9291f044a93d';

const kDefaultWorkchain = 0;

const kProviderVersion = '0.2.26';

const kDefaultMessageExpiration = Expiration.timeout(value: 60);

const kAvailableWallets = [
  WalletType.multisig(multisigType: MultisigType.safeMultisigWallet),
  WalletType.multisig(multisigType: MultisigType.safeMultisigWallet24h),
  WalletType.multisig(multisigType: MultisigType.setcodeMultisigWallet),
  WalletType.multisig(multisigType: MultisigType.setcodeMultisigWallet24h),
  WalletType.multisig(multisigType: MultisigType.bridgeMultisigWallet),
  WalletType.multisig(multisigType: MultisigType.surfWallet),
  WalletType.walletV3(),
];

const kNetworkPresets = <ConnectionData>[
  ConnectionData(
    name: 'Mainnet (ADNL)',
    group: 'mainnet',
    type: TransportType.jrpc,
    endpoints: [
      'https://extension-api.broxus.com/rpc',
    ],
    timeout: 60000,
    local: false,
  ),
  ConnectionData(
    name: 'Mainnet (GQL)',
    group: 'mainnet',
    type: TransportType.gql,
    endpoints: [
      'https://main.ton.dev/',
      'https://main2.ton.dev/',
      'https://main3.ton.dev/',
    ],
    timeout: 60000,
    local: false,
  ),
  ConnectionData(
    name: 'Testnet',
    group: 'testnet',
    type: TransportType.gql,
    endpoints: [
      'https://net.ton.dev/',
    ],
    timeout: 60000,
    local: false,
  ),
  ConnectionData(
    name: 'fld.ton.dev',
    group: 'fld',
    type: TransportType.gql,
    endpoints: [
      'https://gql.custler.net/',
    ],
    timeout: 60000,
    local: false,
  ),
];
