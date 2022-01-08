import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final keyInfoProvider = StreamProvider.family<KeyStoreEntry, String>(
  (ref, publicKey) => getIt.get<NekotonService>().keysStream.expand((e) => e).where((e) => e.publicKey == publicKey),
);
