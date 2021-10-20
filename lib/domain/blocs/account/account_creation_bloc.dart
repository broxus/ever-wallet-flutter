import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'account_creation_bloc.freezed.dart';

@injectable
class AccountCreationBloc extends Bloc<AccountCreationEvent, AccountCreationState> {
  final NekotonService _nekotonService;

  AccountCreationBloc(
    this._nekotonService,
  ) : super(const AccountCreationState.initial());

  @override
  Stream<AccountCreationState> mapEventToState(AccountCreationEvent event) async* {
    yield* event.when(
      showOptions: (String publicKey) async* {
        try {
          final added =
              _nekotonService.accounts.where((e) => e.publicKey == publicKey).map((e) => e.tonWallet.contract).toList();

          const available = kAvailableWallets;

          yield AccountCreationState.options(
            added: added,
            available: available,
          );
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield AccountCreationState.error(err.toString());
        }
      },
      createAccount: (
        String name,
        String publicKey,
        WalletType walletType,
      ) async* {
        try {
          await _nekotonService.addAccount(
            name: name,
            publicKey: publicKey,
            walletType: walletType,
            workchain: kDefaultWorkchain,
          );

          yield const AccountCreationState.success();
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield AccountCreationState.error(err.toString());
        }
      },
    );
  }
}

@freezed
class AccountCreationEvent with _$AccountCreationEvent {
  const factory AccountCreationEvent.showOptions(String publicKey) = _ShowOptions;

  const factory AccountCreationEvent.createAccount({
    required String name,
    required String publicKey,
    required WalletType walletType,
  }) = _CreateAccount;
}

@freezed
class AccountCreationState with _$AccountCreationState {
  const factory AccountCreationState.initial() = _Initial;

  const factory AccountCreationState.options({
    required List<WalletType> added,
    required List<WalletType> available,
  }) = _Options;

  const factory AccountCreationState.success() = _Success;

  const factory AccountCreationState.error(String info) = _Error;
}
