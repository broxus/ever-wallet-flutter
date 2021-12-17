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

part 'accounts_bloc.freezed.dart';

@injectable
class AccountsBloc extends Bloc<_Event, List<Account>> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<Exception>();
  late final StreamSubscription _streamSubscription;

  AccountsBloc(this._nekotonService) : super(const []) {
    _streamSubscription =
        Rx.combineLatest3<KeyStoreEntry?, List<AssetsList>, Map<String, List<AssetsList>>, List<Account>>(
      _nekotonService.currentKeyStream,
      _nekotonService.accountsStream,
      _nekotonService.externalAccountsStream,
      (a, b, c) => [
        ...b.where((e) => e.publicKey == a?.publicKey).map((e) => Account.internal(assetsList: e)),
        ...(c[a?.publicKey] ?? []).map((e) => Account.external(assetsList: e)),
      ],
    ).distinct((previous, next) => listEquals(previous, next)).listen((event) => add(_Event.update(event)));
  }

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription.cancel();
    return super.close();
  }

  @override
  Stream<List<Account>> mapEventToState(_Event event) async* {
    try {
      if (event is _Update) {
        yield event.accounts;
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err);
    }
  }

  Stream<Exception> get errorsStream => _errorsSubject.stream;
}

@freezed
class _Event with _$_Event {
  const factory _Event.update(List<Account> accounts) = _Update;
}
