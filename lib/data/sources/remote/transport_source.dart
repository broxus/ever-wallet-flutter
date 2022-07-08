import 'dart:async';

import 'package:ever_wallet/data/models/connection_data.dart';
import 'package:ever_wallet/data/sources/remote/http_source.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

class TransportSource {
  final HttpSource _httpSource;
  final _transportSubject = BehaviorSubject<Transport>();

  TransportSource(this._httpSource);

  Stream<Transport> get transportStream => _transportSubject;

  Future<Transport> get transport => _transportSubject.first;

  Future<void> updateTransport(ConnectionData connectionData) async {
    final prevTransport = _transportSubject.valueOrNull;

    _transportSubject.add(_createTransport(connectionData));

    if (prevTransport != null) prevTransport.dispose();
  }

  Future<void> dispose() async {
    final transport = _transportSubject.valueOrNull;

    await _transportSubject.close();

    await transport?.dispose();
  }

  Transport _createTransport(ConnectionData connectionData) => connectionData.when(
        gql: (name, group, endpoints, timeout, local) => _createGqlTransport(
          name: name,
          group: group,
          endpoints: endpoints,
          local: local,
        ),
        jrpc: (name, group, endpoint) => _createJrpcTransport(
          name: name,
          group: group,
          endpoint: endpoint,
        ),
      );

  GqlTransport _createGqlTransport({
    required String name,
    required String group,
    required List<String> endpoints,
    required bool local,
  }) =>
      GqlTransport(
        GqlConnection(
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
          group: group,
          settings: GqlNetworkSettings(
            endpoints: endpoints,
            latencyDetectionInterval: 60000,
            maxLatency: 60000,
            endpointSelectionRetryCount: 5,
            local: local,
          ),
        ),
      );

  JrpcTransport _createJrpcTransport({
    required String name,
    required String group,
    required String endpoint,
  }) =>
      JrpcTransport(
        JrpcConnection(
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
          group: group,
          settings: JrpcNetworkSettings(endpoint: endpoint),
        ),
      );
}
