import 'dart:async';

import 'package:ever_wallet/data/models/connection_data.dart';
import 'package:ever_wallet/data/models/network_type.dart';
import 'package:ever_wallet/data/sources/remote/constants.dart';
import 'package:ever_wallet/data/sources/remote/http_source.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart' hide ConnectionData;
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class TransportSource {
  final HttpSource _httpSource;
  final _transportSubject =
      BehaviorSubject<Tuple2<Transport, ConnectionData>>();

  TransportSource(this._httpSource);

  Stream<Tuple2<Transport, ConnectionData>> get transportWithDataStream =>
      _transportSubject;

  Stream<Transport> get transportStream =>
      _transportSubject.map((event) => event.item1);

  Stream<NetworkType> get networkTypeStream =>
      _transportSubject.map((e) => e.item2.type);

  Tuple2<Transport, ConnectionData> get transportWithData =>
      _transportSubject.value;

  Transport get transport => _transportSubject.value.item1;

  NetworkType get networkType => _transportSubject.value.item2.type;

  Future<void> updateTransport(ConnectionData connectionData) async {
    final prevTransport = _transportSubject.valueOrNull;

    _transportSubject.add(
      Tuple2(_createTransport(connectionData), connectionData),
    );

    await prevTransport?.item1.dispose();
  }

  Future<void> dispose() async {
    await _transportSubject.close();

    await _transportSubject.valueOrNull?.item1.dispose();
  }

  Transport _createTransport(ConnectionData connectionData) =>
      connectionData.when(
        gql: (name, networkId, group, endpoints, _, local, __, ___) =>
            _createGqlTransport(
          name: name,
          networkId: networkId,
          group: group,
          endpoints: endpoints,
          local: local,
        ),
        jrpc: (name, networkId, group, endpoint, _, __) => _createJrpcTransport(
          name: name,
          networkId: networkId,
          group: group,
          endpoint: endpoint,
        ),
      );

  GqlTransport _createGqlTransport({
    required String name,
    required int networkId,
    required String group,
    required List<String> endpoints,
    required bool local,
  }) {
    final settings = GqlNetworkSettings(
      endpoints: endpoints,
      latencyDetectionInterval: kDefaultLatencyDetectionInterval,
      maxLatency: kDefaultMaxLatency,
      endpointSelectionRetryCount: kDefaultEndpointSelectionRetryCount,
      local: local,
    );

    final connection = GqlConnection(
      post: ({
        required endpoint,
        required headers,
        required data,
      }) async =>
          _httpSource.postTransportData(
        endpoint: endpoint,
        headers: headers,
        data: data,
      ),
      get: (endpoint) async => _httpSource.getTransportData(endpoint),
      name: name,
      networkId: networkId,
      group: group,
      settings: settings,
    );

    final transport = GqlTransport(connection);

    return transport;
  }

  JrpcTransport _createJrpcTransport({
    required String name,
    required int networkId,
    required String group,
    required String endpoint,
  }) {
    final settings = JrpcNetworkSettings(endpoint: endpoint);

    final connection = JrpcConnection(
      post: ({
        required endpoint,
        required headers,
        required data,
      }) async =>
          _httpSource.postTransportData(
        endpoint: endpoint,
        headers: headers,
        data: data,
      ),
      name: name,
      networkId: networkId,
      group: group,
      settings: settings,
    );

    final transport = JrpcTransport(connection);

    return transport;
  }
}
