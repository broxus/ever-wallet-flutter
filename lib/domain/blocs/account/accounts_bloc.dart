import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';

part 'accounts_bloc.freezed.dart';

@injectable
class AccountsBloc extends Bloc<_Event, AccountsState> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<Exception>();
  late final StreamSubscription _streamSubscription;

  AccountsBloc(this._nekotonService) : super(const AccountsState()) {
    _streamSubscription = Rx.combineLatest2<KeyStoreEntry?, List<AssetsList>, List<AssetsList>>(
      _nekotonService.currentKeyStream,
      _nekotonService.accountsStream,
      (a, b) => b.where((e) => e.publicKey == a?.publicKey).toList(),
    ).distinct((previous, next) => listEquals(previous, next)).listen((event) => add(_LocalEvent.update(event)));
  }

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription.cancel();
    return super.close();
  }

  @override
  Stream<AccountsState> mapEventToState(_Event event) async* {
    try {
      if (event is _SetCurrent) {
        final currentAccount = _nekotonService.accounts.firstWhereOrNull((e) => e.address == event.address);

        yield AccountsState(
          accounts: state.accounts,
          currentAccount: currentAccount,
        );
      } else if (event is _Update) {
        final currentAccount = event.accounts.firstWhereOrNull((e) => e.address == state.currentAccount?.address) ??
            event.accounts.firstOrNull;

        yield AccountsState(
          accounts: event.accounts,
          currentAccount: currentAccount,
        );
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err);
    }
  }

  Stream<Exception> get errorsStream => _errorsSubject.stream;
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.update(List<AssetsList> accounts) = _Update;
}

@freezed
class AccountsEvent extends _Event with _$AccountsEvent {
  const factory AccountsEvent.setCurrent(String? address) = _SetCurrent;
}

@freezed
class AccountsState with _$AccountsState {
  const factory AccountsState({
    @Default([]) List<AssetsList> accounts,
    AssetsList? currentAccount,
  }) = _AccountsState;
}
