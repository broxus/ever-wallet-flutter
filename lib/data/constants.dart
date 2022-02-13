import 'package:nekoton_flutter/nekoton_flutter.dart';

const kDefaultWorkchain = 0;

const kProviderVersion = '0.2.13';

const kDefaultMessageExpiration = Expiration.timeout(value: 30);

const kAvailableWallets = [
  WalletType.multisig(multisigType: MultisigType.safeMultisigWallet),
  WalletType.multisig(multisigType: MultisigType.safeMultisigWallet24h),
  WalletType.multisig(multisigType: MultisigType.setcodeMultisigWallet),
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
