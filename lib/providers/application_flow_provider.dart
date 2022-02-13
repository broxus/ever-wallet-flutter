import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../injection.dart';
import '../../data/models/application_flow_state.dart';
import '../../data/repositories/accounts_storage_repository.dart';
import '../../data/repositories/biometry_repository.dart';
import '../../data/repositories/external_accounts_repository.dart';
import '../../data/repositories/keystore_repository.dart';
import '../../data/repositories/token_wallet_info_repository.dart';
import '../../data/repositories/token_wallet_transactions_repository.dart';
import '../../data/repositories/ton_assets_repository.dart';
import '../../data/repositories/ton_wallet_info_repository.dart';
import '../../data/repositories/ton_wallet_transactions_repository.dart';
import 'key/keys_presence_provider.dart';

final applicationFlowProvider = StateNotifierProvider.autoDispose<ApplicationFlowNotifier, ApplicationFlowState>((ref) {
  final notifier = ApplicationFlowNotifier(ref.read);

  scheduleMicrotask(() {
    ref.onDispose(
      ref.listen<AsyncValue<bool>>(
        keysPresenceProvider,
        notifier.callback,
        fireImmediately: true,
      ),
    );
  });

  return notifier;
});

class ApplicationFlowNotifier extends StateNotifier<ApplicationFlowState> {
  final Reader read;

  ApplicationFlowNotifier(this.read) : super(const ApplicationFlowState.loading());

  Future<void> logOut() async {
    state = const ApplicationFlowState.loading();

    await getIt.get<KeystoreRepository>().clear();
    await getIt.get<AccountsStorageRepository>().clear();
    await getIt.get<ExternalAccountsRepository>().clear();
    await getIt.get<BiometryRepository>().clear();
    await getIt.get<TonAssetsRepository>().clear();
    await getIt.get<TonWalletInfoRepository>().clear();
    await getIt.get<TokenWalletInfoRepository>().clear();
    await getIt.get<TonWalletTransactionsRepository>().clear();
    await getIt.get<TokenWalletTransactionsRepository>().clear();
  }

  void callback(
    AsyncValue<bool>? previous,
    AsyncValue<bool> next,
  ) {
    final hasKeys = next.asData?.value ?? false;

    if (hasKeys) {
      state = const ApplicationFlowState.home();

      getIt.get<TonAssetsRepository>().refresh();
    } else {
      state = const ApplicationFlowState.welcome();
    }
  }
}