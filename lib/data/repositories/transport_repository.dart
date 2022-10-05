import 'dart:async';

import 'package:collection/collection.dart';
import 'package:ever_wallet/data/models/connection_data.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/data/sources/remote/transport_source.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class TransportRepository {
  final HiveSource _hiveSource;
  final TransportSource _transportSource;
  final _networkPresets = const <ConnectionData>[
    ConnectionData.jrpc(
      name: 'Mainnet (ADNL)',
      networkId: 1,
      group: 'mainnet',
      endpoint: 'https://jrpc.everwallet.net/rpc',
    ),
    ConnectionData.gql(
      name: 'Mainnet (GQL)',
      networkId: 1,
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
      networkId: 2,
      group: 'testnet',
      endpoints: [
        'https://eri01.net.everos.dev/graphql',
        'https://rbx01.net.everos.dev/graphql',
        'https://gra01.net.everos.dev/graphql',
      ],
      timeout: 60000,
      local: false,
    ),
    ConnectionData.jrpc(
      name: 'Mainnet Venom (ADNL)',
      networkId: 1000,
      group: 'venom_mainnet',
      endpoint: 'https://jrpc.venom.foundation/rpc',
    ),
    ConnectionData.gql(
      name: 'fld.ton.dev',
      networkId: 10,
      group: 'fld',
      endpoints: [
        'https://gql.custler.net/graphql',
      ],
      timeout: 60000,
      local: false,
    ),
    ConnectionData.gql(
      name: 'Gosh',
      networkId: 30,
      group: 'gosh',
      endpoints: [
        'https://network.gosh.sh',
      ],
      timeout: 60000,
      local: false,
    ),
    ConnectionData.gql(
      name: 'Local node',
      networkId: 31337,
      group: 'localnet',
      endpoints: [
        'https://127.0.0.1',
      ],
      timeout: 60000,
      local: false,
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

  Transport get transport => _transportSource.transport;

  Future<void> updateTransport(ConnectionData connectionData) async {
    await _hiveSource.setCurrentConnection(connectionData.name);

    await _transportSource.updateTransport(connectionData);
  }

  Future<void> _initialize() async {
    var currentConnection =
        networkPresets.firstWhereOrNull((e) => e.name == _hiveSource.currentConnection);

    if (currentConnection == null) {
      currentConnection = networkPresets.first;

      await _hiveSource.setCurrentConnection(currentConnection.name);
    }

    await _transportSource.updateTransport(currentConnection);
  }
}
