import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:crystal/logger.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../services/nekoton_service.dart';

part 'account_creation_options_bloc.freezed.dart';

@injectable
class AccountCreationOptionsBloc extends Bloc<AccountCreationOptionsEvent, AccountCreationOptionsState> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<String>();

  AccountCreationOptionsBloc(this._nekotonService) : super(const AccountCreationOptionsState());

  @override
  Future<void> close() {
    _errorsSubject.close();
    return super.close();
  }

  @override
  Stream<AccountCreationOptionsState> mapEventToState(AccountCreationOptionsEvent event) async* {
    try {
      if (event is _Show) {
        final added = _nekotonService.accounts
            .where((e) => e.publicKey == event.publicKey)
            .map((e) => e.tonWallet.contract)
            .toList();

        final available = kAvailableWallets.where((e) => !added.contains(e)).toList();

        yield AccountCreationOptionsState(
          added: added,
          available: available,
        );
      }
    } catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err.toString());
    }
  }

  Stream<String> get errorsStream => _errorsSubject.stream;
}

@freezed
class AccountCreationOptionsEvent with _$AccountCreationOptionsEvent {
  const factory AccountCreationOptionsEvent.show(String publicKey) = _Show;
}

@freezed
class AccountCreationOptionsState with _$AccountCreationOptionsState {
  const factory AccountCreationOptionsState({
    @Default([]) List<WalletType> added,
    @Default([]) List<WalletType> available,
  }) = _AccountCreationOptionsState;
}
