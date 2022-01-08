import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../services/nekoton_service.dart';

@lazySingleton
class TransportRepository {
  final NekotonService _nekotonService;

  TransportRepository(this._nekotonService);

  Future<void> updateTransport(ConnectionData connectionData) => _nekotonService.updateTransport(connectionData);
}
