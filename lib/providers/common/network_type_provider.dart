import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../injection.dart';
import '../../../logger.dart';
import '../../data/repositories/transport_repository.dart';

final networkTypeProvider = StreamProvider.autoDispose<String>(
  (ref) => getIt.get<TransportRepository>().transportStream.map((e) {
    final isEver = !e.connectionData.name.contains('Venom');

    return isEver ? 'Ever' : 'Venom';
  }).doOnError((err, st) => logger.e(err, err, st)),
);
