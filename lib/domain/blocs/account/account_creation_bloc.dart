import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'account_creation_bloc.freezed.dart';

@injectable
class AccountCreationBloc extends Bloc<AccountCreationEvent, AccountCreationState> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<String>();

  AccountCreationBloc(this._nekotonService) : super(const AccountCreationState.initial());

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

        yield const AccountCreationState.success();
      }
    } catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err.toString());
    }
  }

  Stream<String> get errorsStream => _errorsSubject.stream;
}

@freezed
class AccountCreationEvent with _$AccountCreationEvent {
  const factory AccountCreationEvent.create({
    required String name,
    required String publicKey,
    required WalletType walletType,
  }) = _Create;
}

@freezed
class AccountCreationState with _$AccountCreationState {
  const factory AccountCreationState.initial() = _Initial;

  const factory AccountCreationState.success() = _Success;
}
