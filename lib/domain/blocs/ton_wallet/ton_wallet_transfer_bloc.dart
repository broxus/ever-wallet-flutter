import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../injection.dart';
import '../../../logger.dart';
import '../../constants/message_expiration.dart';
import '../../services/nekoton_service.dart';
import 'ton_wallet_fees_bloc.dart';

part 'ton_wallet_transfer_bloc.freezed.dart';

@injectable
class TonWalletTransferBloc extends Bloc<_Event, TonWalletTransferState> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<String>();
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
  Future<void> close() {
    _errorsSubject.close();
    return super.close();
  }

  @override
  Stream<TonWalletTransferState> mapEventToState(_Event event) async* {
    try {
      if (event is _PrepareTransfer) {
        final repackedDestination = repackAddress(event.destination);

        final tonWallet = _nekotonService.tonWallets.firstWhere((e) => e.address == _address!);

        final int? _nanoAmount = int.tryParse(event.amount.fromTokens());
        if (_nanoAmount != null) {
          _message = await tonWallet.prepareTransfer(
            expiration: defaultMessageExpiration,
            destination: repackedDestination,
            amount: _nanoAmount,
            body: event.comment,
          );
          feesBloc.add(TonWalletFeesEvent.estimateFees(nanoAmount: _nanoAmount, message: _message!));

          final contractState = await tonWallet.contractState;

          yield TonWalletTransferState.messagePrepared(
            balance: contractState.balance.toTokens(),
            amount: event.amount,
            destination: event.destination,
            comment: event.comment,
          );
        }
      } else if (event is _GoToPassword) {
        yield const TonWalletTransferState.password();
      } else if (event is _BackToInitial) {
        final tonWallet = _nekotonService.tonWallets.firstWhere((e) => e.address == _address!);

        final contractState = await tonWallet.contractState;
        final balance = contractState.balance;
        yield TonWalletTransferState.initial(balance.toTokens());
      } else if (event is _Send) {
        final tonWallet = _nekotonService.tonWallets.firstWhere((e) => e.address == _address!);

        if (_message != null) {
          yield const TonWalletTransferState.sending();
          await tonWallet.send(
            message: _message!,
            password: event.password,
          );

          yield const TonWalletTransferState.success();
        }
      } else if (event is _GetBalance) {
        final tonWallet = _nekotonService.tonWallets.firstWhere((e) => e.address == _address!);

        final contractState = await tonWallet.contractState;
        final balance = contractState.balance;
        yield TonWalletTransferState.initial(balance.toTokens());
      }
    } catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err.toString());
    }
  }

  Stream<String> get errorsStream => _errorsSubject.stream;
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
