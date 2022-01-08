import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final accountInfoProvider = StreamProvider.family<AssetsList, String>(
  (ref, address) => getIt.get<NekotonService>().accountsStream.expand((e) => e).where((e) => e.address == address),
);
