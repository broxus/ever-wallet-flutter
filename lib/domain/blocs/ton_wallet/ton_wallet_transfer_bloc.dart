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
import 'ton_wallet_fees_bloc.dart';

part 'ton_wallet_transfer_bloc.freezed.dart';

@injectable
class TonWalletTransferBloc extends Bloc<_Event, TonWalletTransferState> {
  final NekotonService _nekotonService;
  final String? _address;
  UnsignedMessage? _message;
  late TonWalletFeesBloc feesBloc;

  TonWalletTransferBloc(
    this._nekotonService,
    @factoryParam this._address,
  ) : super(const TonWalletTransferState.initial()) {
    feesBloc = getIt.get<TonWalletFeesBloc>(param1: _address);
    add(const _LocalEvent.getBalance());
  }

  @override
  Stream<TonWalletTransferState> mapEventToState(_Event event) async* {
    if (event is TonWalletTransferEvent) {
      yield* event.when(
        prepareTransfer: (
          String destination,
          String amount,
          String? comment,
        ) async* {
          try {
            final repackedDestination = repackAddress(destination);

            final tonWallet = _nekotonService.tonWallets.firstWhere((e) => e.address == _address!);

            final int? _nanoAmount = int.tryParse(amount.fromTokens());
            if (_nanoAmount != null) {
              _message = await tonWallet.prepareTransfer(
                expiration: defaultMessageExpiration,
                destination: repackedDestination,
                amount: _nanoAmount,
                body: comment,
              );
              feesBloc.add(TonWalletFeesEvent.estimateFees(nanoAmount: _nanoAmount, message: _message!));

              final contractState = await tonWallet.contractState;

              yield TonWalletTransferState.messagePrepared(
                balance: contractState.balance.toTokens(),
                amount: amount,
                destination: destination,
                comment: comment,
              );
            }
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield TonWalletTransferState.error(err.getMessage());
          }
        },
        goToPassword: () async* {
          yield const TonWalletTransferState.password();
        },
        backToInitial: () async* {
          final tonWallet = _nekotonService.tonWallets.firstWhere((e) => e.address == _address!);

          final contractState = await tonWallet.contractState;
          final balance = contractState.balance;
          yield TonWalletTransferState.initial(balance.toTokens());
        },
        send: (String password) async* {
          try {
            final tonWallet = _nekotonService.tonWallets.firstWhere((e) => e.address == _address!);

            if (_message != null) {
              yield const TonWalletTransferState.sending();
              await tonWallet.send(
                message: _message!,
                password: password,
              );

              yield const TonWalletTransferState.success();
            }
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield TonWalletTransferState.error(err.getMessage());
          }
        },
      );
    } else if (event is _GetBalance) {
      final tonWallet = _nekotonService.tonWallets.firstWhere((e) => e.address == _address!);

      final contractState = await tonWallet.contractState;
      final balance = contractState.balance;
      yield TonWalletTransferState.initial(balance.toTokens());
    }
  }
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.getBalance() = _GetBalance;
}

@freezed
class TonWalletTransferEvent extends _Event with _$TonWalletTransferEvent {
  const factory TonWalletTransferEvent.prepareTransfer({
    required String destination,
    required String amount,
    String? comment,
  }) = _PrepareTransfer;

  const factory TonWalletTransferEvent.send(String password) = _Send;

  const factory TonWalletTransferEvent.goToPassword() = _GoToPassword;

  const factory TonWalletTransferEvent.backToInitial() = _BackToInitial;
}

@freezed
class TonWalletTransferState with _$TonWalletTransferState {
  const factory TonWalletTransferState.initial([String? balance]) = _Initial;

  const factory TonWalletTransferState.messagePrepared({
    required String balance,
    required String amount,
    required String destination,
    String? comment,
    String? password,
  }) = _MessagePrepared;

  const factory TonWalletTransferState.password() = _Password;

  const factory TonWalletTransferState.success() = _Success;

  const factory TonWalletTransferState.sending() = _Sending;

  const factory TonWalletTransferState.error(String info) = _Error;
}
