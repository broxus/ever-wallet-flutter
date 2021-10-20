import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../injection.dart';
import '../../../logger.dart';
import '../../constants/message_expiration.dart';
import '../../services/nekoton_service.dart';
import '../../utils/error_message.dart';
import 'token_wallet_fees_bloc.dart';

part 'token_wallet_transfer_bloc.freezed.dart';

@injectable
class TokenWalletTransferBloc extends Bloc<_Event, TokenWalletTransferState> {
  final NekotonService _nekotonService;
  final String? _owner;
  final String? _rootTokenContract;
  late TokenWalletFeesBloc feesBloc;
  UnsignedMessage? _message;

  TokenWalletTransferBloc(
    this._nekotonService,
    @factoryParam this._owner,
    @factoryParam this._rootTokenContract,
  ) : super(const TokenWalletTransferState.initial()) {
    feesBloc = getIt.get<TokenWalletFeesBloc>(param1: _owner, param2: _rootTokenContract);
    add(const _LocalEvent.getBalance());
  }

  @override
  Stream<TokenWalletTransferState> mapEventToState(_Event event) async* {
    if (event is _LocalEvent) {
      final tokenWallet = _nekotonService.tokenWallets
          .firstWhere((e) => e.owner == _owner! && e.symbol.rootTokenContract == _rootTokenContract!);

      final balance = await tokenWallet.balance;

      yield TokenWalletTransferState.initial(
        balance: balance.toTokens(tokenWallet.symbol.decimals),
        currency: tokenWallet.symbol.name,
      );
    }

    if (event is TokenWalletTransferEvent) {
      yield* event.when(
        prepareTransfer: (
          String destination,
          String tokens,
          bool notifyReceiver,
        ) async* {
          try {
            final repackedDestination = repackAddress(destination);

            final tokenWallet = _nekotonService.tokenWallets
                .firstWhere((e) => e.owner == _owner! && e.symbol.rootTokenContract == _rootTokenContract!);

            final decimals = tokenWallet.symbol.decimals;

            final nanoTokens = tokens.fromTokens(decimals);

            _message = await tokenWallet.prepareTransfer(
              expiration: defaultMessageExpiration,
              destination: repackedDestination,
              tokens: nanoTokens,
              notifyReceiver: notifyReceiver,
            );
            feesBloc.add(TokenWalletFeesEvent.estimateFees(nanoTokens: nanoTokens, message: _message!));

            final ownerContractState = await tokenWallet.ownerContractState;
            final ownerBalance = ownerContractState.balance;

            final currency = tokenWallet.symbol.name;

            final balance = await tokenWallet.balance;

            yield TokenWalletTransferState.messagePrepared(
              ownerBalance: ownerBalance.toTokens(),
              balance: balance.toTokens(decimals),
              currency: currency,
              tokens: tokens,
              destination: destination,
            );
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield TokenWalletTransferState.error(err.getMessage());
          }
        },
        send: (String password) async* {
          if (_message != null) {
            try {
              final tokenWallet = _nekotonService.tokenWallets
                  .firstWhere((e) => e.owner == _owner! && e.symbol.rootTokenContract == _rootTokenContract!);

              yield const TokenWalletTransferState.sending();
              await tokenWallet.send(
                message: _message!,
                password: password,
              );

              yield const TokenWalletTransferState.success();
            } on Exception catch (err, st) {
              logger.e(err, err, st);
              yield TokenWalletTransferState.error(err.getMessage());
            }
          }
        },
        goToPassword: () async* {
          yield const TokenWalletTransferState.password();
        },
        backToInitial: () async* {
          final tokenWallet = _nekotonService.tokenWallets
              .firstWhere((e) => e.owner == _owner! && e.symbol.rootTokenContract == _rootTokenContract!);

          final contractState = await tokenWallet.contractState;
          final balance = contractState.balance;
          yield TokenWalletTransferState.initial(balance: balance.toTokens());
        },
      );
    }
  }
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.getBalance() = _GetBalance;
}

@freezed
class TokenWalletTransferEvent extends _Event with _$TokenWalletTransferEvent {
  const factory TokenWalletTransferEvent.prepareTransfer({
    required String destination,
    required String tokens,
    required bool notifyReceiver,
  }) = _PrepareTransfer;

  const factory TokenWalletTransferEvent.send(String password) = _Send;

  const factory TokenWalletTransferEvent.goToPassword() = _GoToPassword;

  const factory TokenWalletTransferEvent.backToInitial() = _BackToInitial;
}

@freezed
class TokenWalletTransferState with _$TokenWalletTransferState {
  const factory TokenWalletTransferState.initial({
    String? balance,
    String? currency,
  }) = _Initial;

  const factory TokenWalletTransferState.messagePrepared({
    required String ownerBalance,
    required String balance,
    required String currency,
    required String tokens,
    required String destination,
  }) = _MessagePrepared;

  const factory TokenWalletTransferState.success() = _Success;

  const factory TokenWalletTransferState.password() = _Password;

  const factory TokenWalletTransferState.sending() = _Sending;

  const factory TokenWalletTransferState.error(String info) = _Error;
}
