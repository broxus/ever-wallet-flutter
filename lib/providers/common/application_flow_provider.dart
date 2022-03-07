import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../injection.dart';
import '../../../data/models/application_flow_state.dart';
import '../../../data/repositories/biometry_repository.dart';
import '../../../data/repositories/ton_assets_repository.dart';
import '../../data/repositories/accounts_repository.dart';
import '../../data/repositories/keys_repository.dart';

final applicationFlowProvider = StateNotifierProvider.autoDispose<ApplicationFlowNotifier, ApplicationFlowState>(
  (ref) => ApplicationFlowNotifier(),
);

class ApplicationFlowNotifier extends StateNotifier<ApplicationFlowState> {
  late final StreamSubscription _streamSubscription;

  ApplicationFlowNotifier() : super(const ApplicationFlowState.loading()) {
    _streamSubscription =
        getIt.get<KeysRepository>().keysStream.map((e) => e.isNotEmpty).listen((event) => _keysStreamListener(event));
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  Future<void> logOut() async {
    state = const ApplicationFlowState.loading();

    await getIt.get<KeysRepository>().clear();
    await getIt.get<AccountsRepository>().clear();
    await getIt.get<BiometryRepository>().clear();
    await getIt.get<TonAssetsRepository>().clear();
  }

  void _keysStreamListener(bool event) {
    if (event) {
      state = const ApplicationFlowState.home();
    } else {
      state = const ApplicationFlowState.welcome();
    }
  }
}
