import 'dart:async';

import 'package:ever_wallet/data/models/connection_data.dart';
import 'package:ever_wallet/data/sources/remote/constants.dart';
import 'package:ever_wallet/data/sources/remote/http_source.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

class TransportSource {
  final HttpSource _httpSource;
  final _transportSubject = BehaviorSubject<Transport>();

  TransportSource(this._httpSource);

  Stream<Transport> get transportStream => _transportSubject;

  Transport get transport => _transportSubject.value;

  /// Returns stream of bool where true means ever network, false means venom network
  Stream<bool> get isEverTransportStream => transportStream.map((t) => !t.name.contains('Venom'));

  bool get isEverTransport => !transport.name.contains('Venom');

  Future<void> updateTransport(ConnectionData connectionData) async {
    final prevTransport = _transportSubject.valueOrNull;

    _transportSubject.add(_createTransport(connectionData));

    await prevTransport?.dispose();
  }

  Future<void> dispose() async {
    await _transportSubject.close();

    await _transportSubject.valueOrNull?.dispose();
  }

  Transport _createTransport(ConnectionData connectionData) => connectionData.when(
        gql: (name, networkId, group, endpoints, timeout, local) => _createGqlTransport(
          name: name,
          networkId: networkId,
          group: group,
          endpoints: endpoints,
          local: local,
        ),
        jrpc: (name, networkId, group, endpoint) => _createJrpcTransport(
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
