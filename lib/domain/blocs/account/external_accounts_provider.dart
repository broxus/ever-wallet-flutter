import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/services/nekoton_service.dart';
import '../../../../injection.dart';
import '../key/current_key_provider.dart';

final externalAccountsProvider = StreamProvider<List<String>>((ref) {
  final currentKey = ref.watch(currentKeyProvider).asData?.value;

  return getIt.get<NekotonService>().externalAccountsStream.map((e) => e[currentKey?.publicKey] ?? []);
});
