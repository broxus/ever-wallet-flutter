import 'package:ever_wallet/data/models/connection_data.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

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

const kNetworkPresets = <ConnectionData>[
  ConnectionData.jrpc(
    name: 'Mainnet (ADNL)',
    group: 'mainnet',
    endpoint: 'https://jrpc.everwallet.net/rpc',
  ),
  ConnectionData.gql(
    name: 'Mainnet (GQL)',
    group: 'mainnet',
    endpoints: [
      'https://eri01.main.everos.dev/graphql',
      'https://gra01.main.everos.dev/graphql',
      'https://gra02.main.everos.dev/graphql',
      'https://lim01.main.everos.dev/graphql',
      'https://rbx01.main.everos.dev/graphql',
    ],
    timeout: 60000,
    local: false,
  ),
  ConnectionData.gql(
    name: 'Testnet',
    group: 'testnet',
    endpoints: [
      'https://eri01.net.everos.dev/graphql',
      'https://rbx01.net.everos.dev/graphql',
      'https://gra01.net.everos.dev/graphql',
    ],
    timeout: 60000,
    local: false,
  ),
  ConnectionData.gql(
    name: 'fld.ton.dev',
    group: 'fld',
    endpoints: [
      'https://gql.custler.net/graphql',
    ],
    timeout: 60000,
    local: false,
  ),
  ConnectionData.gql(
    name: 'Local node',
    group: 'localnet',
    endpoints: [
      'http://127.0.0.1/graphql',
    ],
    timeout: 60000,
    local: false,
  ),
];
