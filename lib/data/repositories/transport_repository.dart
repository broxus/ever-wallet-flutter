import 'dart:async';

import 'package:collection/collection.dart';
import 'package:ever_wallet/data/models/connection_data.dart';
import 'package:ever_wallet/data/models/network_config.dart';
import 'package:ever_wallet/data/models/network_type.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/data/sources/remote/transport_source.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart' hide ConnectionData;
import 'package:tuple/tuple.dart';

const _everConfig = NetworkConfig(
  symbol: 'EVER',
  explorerBaseUrl: 'https://everscan.io',
  tokensManifestUrl:
      'https://raw.githubusercontent.com/broxus/ton-assets/master/manifest.json',
  currenciesApiBaseUrl: 'https://api.flatqube.io/v1/currencies',
);
const _venomConfig = NetworkConfig(
  symbol: 'VENOM',
  explorerBaseUrl: 'https://venomscan.com',
  tokensManifestUrl:
      'https://cdn.venom.foundation/assets/mainnet/manifest.json',
  currenciesApiBaseUrl: 'https://api.web3.world/v1/currencies',
);
const _tychoConfig = NetworkConfig(
  symbol: 'Tycho',
  explorerBaseUrl: 'https://testnet.tychoprotocol.com',
  tokensManifestUrl:
      'https://raw.githubusercontent.com/broxus/ton-assets/refs/heads/tychotestnet/manifest.json',
  currenciesApiBaseUrl: 'https://api-test-tycho.flatqube.io/v1/currencies',
);

class TransportRepository {
  final HiveSource _hiveSource;
  final TransportSource _transportSource;
  final _networkPresets = const <ConnectionData>[
    ConnectionData.jrpc(
      name: 'Mainnet (JRPC)',
      networkId: 1,
      group: 'mainnet',
      endpoint: 'https://jrpc.everwallet.net/rpc',
      config: _everConfig,
      type: NetworkType.everscale,
    ),
    ConnectionData.gql(
      name: 'Mainnet (GQL)',
      networkId: 1,
      group: 'mainnet',
      endpoints: [
        'https://mainnet.evercloud.dev/89a3b8f46a484f2ea3bdd364ddaee3a3/graphql',
      ],
      timeout: 60000,
      local: false,
      config: _everConfig,
      type: NetworkType.everscale,
    ),
    ConnectionData.jrpc(
      name: 'Venom',
      networkId: 1000,
      group: 'venom_mainnet',
      endpoint: 'https://jrpc.venom.foundation/rpc',
      config: _venomConfig,
      type: NetworkType.venom,
    ),
    ConnectionData.jrpc(
      name: 'Tycho Testnet',
      networkId: 2000,
      group: 'tycho_testnet',
      endpoint: 'https://rpc-testnet.tychoprotocol.com',
      config: _tychoConfig,
      type: NetworkType.tycho,
    ),
  ];

  TransportRepository._({
    required HiveSource hiveSource,
    required TransportSource transportSource,
  })  : _hiveSource = hiveSource,
        _transportSource = transportSource;

  static Future<TransportRepository> create({
    required HiveSource hiveSource,
    required TransportSource transportSource,
  }) async {
    final instance = TransportRepository._(
      hiveSource: hiveSource,
      transportSource: transportSource,
    );
    await instance._initialize();
    return instance;
  }

  List<ConnectionData> get networkPresets => _networkPresets;

  Stream<Transport> get transportStream => _transportSource.transportStream;

  Stream<Tuple2<Transport, ConnectionData>> get transportWithDataStream =>
      _transportSource.transportWithDataStream;

  Stream<NetworkType> get networkTypeStream =>
      _transportSource.networkTypeStream;

  Transport get transport => _transportSource.transport;

  Tuple2<Transport, ConnectionData> get transportWithData =>
      _transportSource.transportWithData;

  NetworkType get networkType => _transportSource.networkType;

  Future<void> updateTransport(ConnectionData connectionData) async {
    await _hiveSource.setCurrentConnection(connectionData.name);

    await _transportSource.updateTransport(connectionData);
  }

  Future<void> _initialize() async {
    var currentConnection = networkPresets
        .firstWhereOrNull((e) => e.name == _hiveSource.currentConnection);

    if (currentConnection == null) {
      currentConnection = networkPresets.first;

      await _hiveSource.setCurrentConnection(currentConnection.name);
    }

    await _transportSource.updateTransport(currentConnection);
  }
}
