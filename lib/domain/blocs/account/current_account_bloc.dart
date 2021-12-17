import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';
import '../../models/account.dart';

part 'current_account_bloc.freezed.dart';

@injectable
class CurrentAccountBloc extends Bloc<_Event, Account?> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<Exception>();
  late final StreamSubscription _streamSubscription;

  CurrentAccountBloc(this._nekotonService) : super(null) {
    _streamSubscription =
        Rx.combineLatest3<KeyStoreEntry?, List<AssetsList>, Map<String, List<AssetsList>>, List<Account>>(
      _nekotonService.currentKeyStream,
      _nekotonService.accountsStream,
      _nekotonService.externalAccountsStream,
      (a, b, c) => [
        ...b.where((e) => e.publicKey == a?.publicKey).map((e) => Account.internal(assetsList: e)),
        ...(c[a?.publicKey] ?? []).map((e) => Account.external(assetsList: e)),
      ],
    ).distinct((previous, next) => listEquals(previous, next)).listen((event) => add(_LocalEvent.update(event)));
  }

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription.cancel();
    return super.close();
  }

  @override
  Stream<Account?> mapEventToState(_Event event) async* {
    try {
      if (event is _SetCurrent) {
        late final Account? account;

        if (!event.isExternal) {
          final assetsList = _nekotonService.accounts.firstWhereOrNull((e) => e.address == event.address);

          account = assetsList != null ? Account.external(assetsList: assetsList) : null;
        } else {
          final assetsList = _nekotonService.externalAccounts[_nekotonService.currentKey?.publicKey]
              ?.firstWhereOrNull((e) => e.address == event.address);

          account = assetsList != null ? Account.internal(assetsList: assetsList) : null;
        }

        yield account;
      } else if (event is _Update) {
        final currentAccount = event.accounts.firstWhereOrNull((e) => e == state) ?? event.accounts.firstOrNull;

        yield currentAccount;
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
  const factory _LocalEvent.update(List<Account> accounts) = _Update;
}

@freezed
class CurrentAccountEvent extends _Event with _$CurrentAccountEvent {
  const factory CurrentAccountEvent.setCurrent({
    String? address,
    @Default(false) bool isExternal,
  }) = _SetCurrent;
}
