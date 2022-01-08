import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final currentKeyProvider = StreamProvider<KeyStoreEntry?>((ref) => getIt.get<NekotonService>().currentKeyStream);
