import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../constants.dart';
import '../sources/local/hive_source.dart';
import '../sources/remote/transport_source.dart';

@preResolve
@lazySingleton
class TransportRepository {
  final TransportSource _transportSource;
  final HiveSource _hiveSource;

  TransportRepository._(
    this._transportSource,
    this._hiveSource,
  );

  @factoryMethod
  static Future<TransportRepository> create({
    required TransportSource transportSource,
    required HiveSource hiveSource,
  }) async {
    final instance = TransportRepository._(
      transportSource,
      hiveSource,
    );
    await instance._initialize();
    return instance;
  }

  Stream<Transport?> get transportStream => _transportSource.transportStream;

  Transport? get transport => _transportSource.transport;

  Future<void> updateTransport(ConnectionData connectionData) async {
    final prevTransport = _transportSource.transport;

    late final Transport transport;

    if (connectionData.type == TransportType.gql) {
      transport = await GqlTransport.create(connectionData);
    } else if (connectionData.type == TransportType.jrpc) {
      transport = await JrpcTransport.create(connectionData);
    } else {
      throw Exception('Invalid connection type');
    }

    _transportSource.transport = transport;

    await _hiveSource.setCurrentConnection(connectionData.name);

    prevTransport?.freePtr();
  }

  Future<void> _initialize() async {
    final currentConnectionName = _hiveSource.currentConnection;

    await updateTransport(
      kNetworkPresets.firstWhere((e) => e.name == currentConnectionName, orElse: () => kNetworkPresets.first),
    );
  }
}
