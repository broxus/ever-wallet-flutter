import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

@lazySingleton
class TransportSource {
  final _transportSubject = BehaviorSubject<Transport?>.seeded(null);

  Stream<Transport?> get transportStream =>
      _transportSubject.stream.distinct((a, b) => a?.connectionData == b?.connectionData);

  Transport? get transport => _transportSubject.value;

  set transport(Transport? transport) => _transportSubject.add(transport);
}
