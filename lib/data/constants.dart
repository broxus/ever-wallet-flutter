import 'package:nekoton_flutter/nekoton_flutter.dart';

const kSubscriptionRefreshTimeout = Duration(seconds: 10);

const kCurrenciesRefreshTimeout = Duration(seconds: 60);

const kAddressForEverCurrency =
    '0:a49cd4e158a9a15555e624759e2e4e766d22600b7800d891e46f9291f044a93d';

const kAddressForVenomCurrency =
    '0:28237a5d5abb32413a79b5f98573074d3b39b72121305d9c9c97912fc06d843c';

const kDefaultWorkchain = 0;

const kProviderVersion = '0.2.31';

const kMessageBounce = false;

const kDefaultMessageExpiration = Expiration.timeout(value: kDefaultMessageTimeout);

const kDefaultMessageTimeout = 60;

const kEverAvailableWallets = [
  WalletType.walletV3(),
  WalletType.multisig(multisigType: MultisigType.safeMultisigWallet),
  WalletType.multisig(multisigType: MultisigType.safeMultisigWallet24h),
  WalletType.multisig(multisigType: MultisigType.setcodeMultisigWallet),
  WalletType.multisig(multisigType: MultisigType.setcodeMultisigWallet24h),
  WalletType.multisig(multisigType: MultisigType.bridgeMultisigWallet),
  WalletType.multisig(multisigType: MultisigType.surfWallet),
];

const kVenomAvailableWallets = [
  WalletType.walletV3(),
  WalletType.multisig(multisigType: MultisigType.bridgeMultisigWallet),
];

const kNetworkPresets = <ConnectionData>[
  ConnectionData(
    name: 'Mainnet (ADNL)',
    networkId: 1,
    group: 'mainnet',
    type: TransportType.jrpc,
    endpoints: [
      'https://jrpc.everwallet.net/rpc',
    ],
    timeout: 60000,
    local: false,
  ),
  ConnectionData(
    name: 'Mainnet (GQL)',
    networkId: 1,
    group: 'mainnet',
    type: TransportType.gql,
    endpoints: [
      'https://eri01.main.everos.dev',
      'https://gra01.main.everos.dev',
      'https://gra02.main.everos.dev',
      'https://lim01.main.everos.dev',
      'https://rbx01.main.everos.dev',
    ],
    timeout: 60000,
    local: false,
  ),
  ConnectionData(
    name: 'Testnet',
    networkId: 2,
    group: 'testnet',
    type: TransportType.gql,
    endpoints: [
      'https://eri01.net.everos.dev',
      'https://rbx01.net.everos.dev',
      'https://gra01.net.everos.dev',
    ],
    timeout: 60000,
    local: false,
  ),
  ConnectionData(
    name: 'Mainnet Venom (ADNL)',
    networkId: 1000,
    group: 'venom_mainnet',
    type: TransportType.jrpc,
    endpoints: [
      'https://jrpc.venom.foundation/rpc',
    ],
    timeout: 60000,
    local: false,
  ),
  ConnectionData(
    name: 'fld.ton.dev',
    networkId: 10,
    group: 'fld',
    type: TransportType.gql,
    endpoints: [
      'https://gql.custler.net',
    ],
    timeout: 60000,
    local: false,
  ),
  ConnectionData(
    name: 'Gosh',
    networkId: 30,
    group: 'gosh',
    type: TransportType.gql,
    endpoints: [
      'https://network.gosh.sh',
    ],
    timeout: 60000,
    local: false,
  ),
  ConnectionData(
    name: 'Local node',
    networkId: 31337,
    group: 'localnet',
    type: TransportType.gql,
    endpoints: [
      'https://127.0.0.1',
    ],
    timeout: 60000,
    local: false,
  ),
];
