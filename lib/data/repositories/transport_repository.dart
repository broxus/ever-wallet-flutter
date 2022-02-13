import 'dart:async';

import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../constants.dart';
import '../sources/local/hive_source.dart';

@preResolve
@lazySingleton
class TransportRepository {
  final HiveSource _hiveSource;
  final _transportSubject = BehaviorSubject<Transport>();

  TransportRepository._(this._hiveSource);

  @factoryMethod
  static Future<TransportRepository> create({
    required HiveSource hiveSource,
  }) async {
    final transportRepository = TransportRepository._(hiveSource);
    await transportRepository._initialize();
    return transportRepository;
  }

  Stream<Transport> get transportStream => _transportSubject.stream;

  Transport get transport => _transportSubject.value;

  Future<void> updateTransport(ConnectionData connectionData) async {
    final old = _transportSubject.valueOrNull;

    late Transport transport;

    if (connectionData.type == TransportType.gql) {
      transport = await GqlTransport.create(connectionData);
    } else if (connectionData.type == TransportType.jrpc) {
      transport = await JrpcTransport.create(connectionData);
    } else {
      throw Exception('Invalid connection type');
    }

    _transportSubject.add(transport);

    await _hiveSource.setCurrentConnection(connectionData.name);

    await old?.freePtr();
  }

  Future<void> _initialize() async {
    final currentConnectionName = _hiveSource.getCurrentConnection();

    final currentConnection = kNetworkPresets.firstWhereOrNull((e) => e.name == currentConnectionName);

    await updateTransport(currentConnection ?? kNetworkPresets.first);
  }
}
