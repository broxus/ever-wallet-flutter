import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';
import '../../models/account.dart';

part 'account_info_bloc.freezed.dart';

@injectable
class AccountInfoBloc extends Bloc<_Event, Account?> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<Exception>();
  StreamSubscription? _streamSubscription;

  AccountInfoBloc(this._nekotonService) : super(null);

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<Account?> mapEventToState(_Event event) async* {
    try {
      if (event is _Load) {
        if (!event.isExternal) {
          final account = _nekotonService.accounts.firstWhereOrNull((e) => e.address == event.address);

          if (account == null) {
            throw AccountNotFoundException();
          }

          _streamSubscription?.cancel();
          _streamSubscription = _nekotonService.accountsStream
              .expand((e) => e)
              .where((e) => e.address == event.address)
              .distinct()
              .listen(
                (value) => add(
                  _LocalEvent.update(
                    Account.external(assetsList: value),
                  ),
                ),
              );
        } else {
          final account = _nekotonService.externalAccounts[_nekotonService.currentKey?.publicKey]
              ?.firstWhereOrNull((e) => e.address == event.address);

          if (account == null) {
            throw ExternalAccountNotFoundException();
          }

          _streamSubscription?.cancel();
          _streamSubscription = _nekotonService.externalAccountsStream
              .map((e) => e[_nekotonService.currentKey?.publicKey] ?? [])
              .expand((e) => e)
              .where((e) => e.address == event.address)
              .distinct()
              .listen(
                (value) => add(
                  _LocalEvent.update(
                    Account.internal(assetsList: value),
                  ),
                ),
              );
        }
      } else if (event is _Update) {
        yield event.account;
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
  const factory _LocalEvent.update(Account account) = _Update;
}

@freezed
class AccountInfoEvent extends _Event with _$AccountInfoEvent {
  const factory AccountInfoEvent.load({
    String? address,
    @Default(false) bool isExternal,
  }) = _Load;
}
