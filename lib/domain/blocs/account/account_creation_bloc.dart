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
  final KeySubject? _keySubject;

  AccountCreationBloc(
    this._nekotonService,
    @factoryParam this._keySubject,
  ) : super(const AccountCreationState.initial()) {
    add(const AccountCreationEvent.showOptions());
  }

  @override
  Stream<AccountCreationState> mapEventToState(AccountCreationEvent event) async* {
    yield* event.when(
      showOptions: () async* {
        try {
          final added = _nekotonService.accounts
              .where((e) => e.value.publicKey == _keySubject!.value.publicKey)
              .map((e) => e.value.tonWallet.contract)
              .toList();

          const available = [
            WalletType.multisig(multisigType: MultisigType.safeMultisigWallet),
            WalletType.multisig(multisigType: MultisigType.safeMultisigWallet24h),
            WalletType.multisig(multisigType: MultisigType.setcodeMultisigWallet),
            WalletType.multisig(multisigType: MultisigType.surfWallet),
            WalletType.walletV3(),
          ];

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
        WalletType walletType,
      ) async* {
        try {
          await _nekotonService.addAccount(
            name: name,
            publicKey: _keySubject!.value.publicKey,
            walletType: walletType,
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
  const factory AccountCreationEvent.showOptions() = _ShowOptions;

  const factory AccountCreationEvent.createAccount({
    required String name,
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
