import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';

part 'account_creation_options_bloc.freezed.dart';

@injectable
class AccountCreationOptionsBloc extends Bloc<_Event, AccountCreationOptionsState> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<Exception>();
  StreamSubscription? _streamSubscription;

  AccountCreationOptionsBloc(this._nekotonService) : super(const AccountCreationOptionsState());

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<AccountCreationOptionsState> mapEventToState(_Event event) async* {
    try {
      if (event is _Load) {
        _streamSubscription?.cancel();
        _streamSubscription = _nekotonService.accountsStream
            .map((e) => e.where((e) => e.publicKey == event.publicKey).toList())
            .map((e) => e.map((e) => e.tonWallet.contract).toList())
            .distinct((previous, next) => listEquals(previous, next))
            .listen((event) {
          final available = kAvailableWallets.where((e) => !event.contains(e)).toList();

          add(
            _LocalEvent.update(
              added: event,
              available: available,
            ),
          );
        });
      } else if (event is _Update) {
        yield AccountCreationOptionsState(
          added: event.added,
          available: event.available,
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
  const factory _LocalEvent.update({
    required List<WalletType> added,
    required List<WalletType> available,
  }) = _Update;
}

@freezed
class AccountCreationOptionsEvent extends _Event with _$AccountCreationOptionsEvent {
  const factory AccountCreationOptionsEvent.load(String publicKey) = _Load;
}

@freezed
class AccountCreationOptionsState with _$AccountCreationOptionsState {
  const factory AccountCreationOptionsState({
    @Default([]) List<WalletType> added,
    @Default([]) List<WalletType> available,
  }) = _AccountCreationOptionsState;
}
