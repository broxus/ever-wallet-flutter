import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

@lazySingleton
class TransportSource {
  final _transportSubject = BehaviorSubject<Transport>();

  Stream<Transport> get transportStream => _transportSubject;

  Future<Transport> get transport => _transportSubject.first;

  void setTransport(Transport transport) => _transportSubject.add(transport);
}
