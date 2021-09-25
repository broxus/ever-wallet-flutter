import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'current_accounts_bloc.freezed.dart';

@injectable
class CurrentAccountsBloc extends Bloc<_Event, CurrentAccountsState> {
  final NekotonService _nekotonService;
  late final StreamSubscription _streamSubscription;
  final _accounts = <AssetsList>[];
  AssetsList? _currentAccount;

  CurrentAccountsBloc(this._nekotonService) : super(const CurrentAccountsState.initial()) {
    _streamSubscription = Rx.combineLatest2<KeyStoreEntry?, List<AssetsList>, List<AssetsList>>(
      _nekotonService.currentKeyStream,
      _nekotonService.accountsStream,
      (a, b) => b.where((e) => e.publicKey == a?.publicKey).toList(),
    ).listen((event) => add(_LocalEvent.updateCurrentAccounts(event)));
  }

  @override
  Future<void> close() {
    _streamSubscription.cancel();
    return super.close();
  }

  @override
  Stream<CurrentAccountsState> mapEventToState(_Event event) async* {
    if (event is _LocalEvent) {
      yield* event.when(
        updateCurrentAccounts: (List<AssetsList> accounts) async* {
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

            yield CurrentAccountsState.ready(
              accounts: [..._accounts],
              currentAccount: _currentAccount,
            );
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield CurrentAccountsState.error(err.toString());
          }
        },
      );
    }

    if (event is CurrentAccountsEvent) {
      yield* event.when(
        setCurrentAccount: (String? address) async* {
          try {
            _currentAccount = _nekotonService.accounts.firstWhereOrNull((e) => e.address == address);

            yield CurrentAccountsState.ready(
              accounts: [..._accounts],
              currentAccount: _currentAccount,
            );
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield CurrentAccountsState.error(err.toString());
          }
        },
      );
    }
  }
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.updateCurrentAccounts(List<AssetsList> accounts) = _UpdateCurrentAccounts;
}

@freezed
class CurrentAccountsEvent extends _Event with _$CurrentAccountsEvent {
  const factory CurrentAccountsEvent.setCurrentAccount(String? address) = _SetCurrentAccount;
}

@freezed
class CurrentAccountsState with _$CurrentAccountsState {
  const factory CurrentAccountsState.initial() = _Initial;

  const factory CurrentAccountsState.ready({
    required List<AssetsList> accounts,
    AssetsList? currentAccount,
  }) = _Ready;

  const factory CurrentAccountsState.error(String info) = _Error;
}
