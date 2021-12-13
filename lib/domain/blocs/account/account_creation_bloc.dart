import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';

part 'account_creation_bloc.freezed.dart';

@injectable
class AccountCreationBloc extends Bloc<AccountCreationEvent, AccountCreationState> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<Exception>();

  AccountCreationBloc(this._nekotonService) : super(AccountCreationStateInitial());

  @override
  Future<void> close() {
    _errorsSubject.close();
    return super.close();
  }

  @override
  Stream<AccountCreationState> mapEventToState(AccountCreationEvent event) async* {
    try {
      if (event is _Create) {
        await _nekotonService.addAccount(
          name: event.name,
          publicKey: event.publicKey,
          walletType: event.walletType,
          workchain: kDefaultWorkchain,
        );

        yield AccountCreationStateSuccess();
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield AccountCreationStateError(err);
    }
  }

  Stream<Exception> get errorsStream => _errorsSubject.stream;
}

@freezed
class AccountCreationEvent with _$AccountCreationEvent {
  const factory AccountCreationEvent.create({
    required String name,
    required String publicKey,
    required WalletType walletType,
  }) = _Create;
}

abstract class AccountCreationState {}

class AccountCreationStateInitial extends AccountCreationState {}

class AccountCreationStateSuccess extends AccountCreationState {}

class AccountCreationStateError extends AccountCreationState {
  final Exception exception;

  AccountCreationStateError(this.exception);
}
