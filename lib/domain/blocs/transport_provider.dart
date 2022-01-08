import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';
import '../../data/services/nekoton_service.dart';

final transportProvider =
    StreamProvider<ConnectionData>((ref) => getIt.get<NekotonService>().transportStream.map((e) => e.connectionData));
