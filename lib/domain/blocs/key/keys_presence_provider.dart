import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final keysPresenceProvider = StreamProvider<bool>((ref) => getIt.get<NekotonService>().keysPresenceStream);
