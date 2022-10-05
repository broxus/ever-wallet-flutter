import 'dart:async';

import 'package:collection/collection.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class CurrentAccountCubit extends Cubit<AssetsList?> {
  final AccountsRepository _accountsRepository;
  late final StreamSubscription _currentAccountsSubscription;

  CurrentAccountCubit(this._accountsRepository)
      : super(_accountsRepository.currentAccounts.firstOrNull) {
    _currentAccountsSubscription =
        _accountsRepository.currentAccountsStream.listen((e) => _currentAccountsStreamListener(e));
  }

  @override
  Future<void> close() async {
    _currentAccountsSubscription.cancel();
    super.close();
  }

  Future<void> setCurrent(String? address) async =>
      emit(_accountsRepository.currentAccounts.firstWhereOrNull((e) => e.address == address));

  void _currentAccountsStreamListener(List<AssetsList> event) {
    if (state == null || event.every((e) => e.address != state?.address)) {
      emit(event.firstOrNull);
    }
  }
}
