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

  const TransportRepository._(
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

  Stream<Transport> get transportStream => _transportSource.transportStream;

  Future<Transport> get transport => _transportSource.transport;

  Future<void> updateTransport(ConnectionData connectionData) async {
    final prevTransport = await _transportSource.transport;

    if (prevTransport.connectionData == connectionData) return;

    final transport = await _create(connectionData);

    _transportSource.setTransport(transport);

    await _hiveSource.setCurrentConnection(connectionData.name);

    prevTransport.freePtr();
  }

  Future<Transport> _create(ConnectionData connectionData) async {
    if (connectionData.type == TransportType.gql) {
      return GqlTransport.create(connectionData);
    } else if (connectionData.type == TransportType.jrpc) {
      return JrpcTransport.create(connectionData);
    } else {
      throw Exception('Invalid connection type');
    }
  }

  Future<void> _initialize() async {
    final currentConnection = kNetworkPresets.firstWhere(
      (e) => e.name == _hiveSource.currentConnection,
      orElse: () => kNetworkPresets.first,
    );

    final transport = await _create(currentConnection);

    _transportSource.setTransport(transport);
  }
}
