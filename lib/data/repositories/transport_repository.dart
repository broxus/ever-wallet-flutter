import 'dart:async';

import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/models/connection_data.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/data/sources/remote/transport_source.dart';
import 'package:ever_wallet/logger.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

class TransportRepository {
  final TransportSource _transportSource;
  final HiveSource _hiveSource;

  TransportRepository(
    this._transportSource,
    this._hiveSource,
  ) {
    final currentConnection = kNetworkPresets.firstWhere(
      (e) => e.name == _hiveSource.currentConnection,
      orElse: () => kNetworkPresets.first,
    );

    _transportSource.updateTransport(currentConnection);
  }

  Stream<Transport> get transportStream => _transportSource.transportStream;

  Future<Transport> get transport => _transportSource.transport;

  Stream<ConnectionData> connectionDataStream() => transportStream
      .map((e) => kNetworkPresets.firstWhere((el) => el.name == e.name))
      .doOnError((err, st) => logger.e(err, err, st));

  Future<void> updateTransport(ConnectionData connectionData) async {
    await _transportSource.updateTransport(connectionData);

    await _hiveSource.setCurrentConnection(connectionData.name);
  }
}
