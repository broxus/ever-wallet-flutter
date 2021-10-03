import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'accounts_bloc.freezed.dart';

@injectable
class AccountsBloc extends Bloc<_Event, AccountsState> {
  final NekotonService _nekotonService;
  late final StreamSubscription _streamSubscription;
  final _accounts = <AssetsList>[];
  AssetsList? _currentAccount;

  AccountsBloc(this._nekotonService) : super(const AccountsState.initial()) {
    _streamSubscription = Rx.combineLatest2<KeyStoreEntry?, List<AssetsList>, List<AssetsList>>(
      _nekotonService.currentKeyStream,
      _nekotonService.accountsStream,
      (a, b) => b.where((e) => e.publicKey == a?.publicKey).toList(),
    ).listen((event) => add(_LocalEvent.updateAccounts(event)));
  }

  @override
  Future<void> close() {
    _streamSubscription.cancel();
    return super.close();
  }

  @override
  Stream<AccountsState> mapEventToState(_Event event) async* {
    if (event is _LocalEvent) {
      yield* event.when(
        updateAccounts: (List<AssetsList> accounts) async* {
          try {
            _accounts
              ..clear()
              ..addAll(accounts);

            final currentAccount = _accounts.firstWhereOrNull((e) => e.address == _currentAccount?.address);

            if (currentAccount == null) {
              _currentAccount = _accounts.firstOrNull;
            } else {
              _currentAccount = currentAccount;
            }

            yield AccountsState.ready(
              accounts: [..._accounts],
              currentAccount: _currentAccount,
            );
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield AccountsState.error(err.toString());
          }
        },
      );
    }

    if (event is AccountsEvent) {
      yield* event.when(
        setCurrentAccount: (String? address) async* {
          try {
            _currentAccount = _nekotonService.accounts.firstWhereOrNull((e) => e.address == address);

            yield AccountsState.ready(
              accounts: [..._accounts],
              currentAccount: _currentAccount,
            );
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield AccountsState.error(err.toString());
          }
        },
      );
    }
  }
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.updateAccounts(List<AssetsList> accounts) = _UpdateAccounts;
}

@freezed
class AccountsEvent extends _Event with _$AccountsEvent {
  const factory AccountsEvent.setCurrentAccount(String? address) = _SetCurrentAccount;
}

@freezed
class AccountsState with _$AccountsState {
  const factory AccountsState.initial() = _Initial;

  const factory AccountsState.ready({
    required List<AssetsList> accounts,
    AssetsList? currentAccount,
  }) = _Ready;

  const factory AccountsState.error(String info) = _Error;
}
