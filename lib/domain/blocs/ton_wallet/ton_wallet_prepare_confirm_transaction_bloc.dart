import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';

part 'ton_wallet_prepare_confirm_transaction_bloc.freezed.dart';

@injectable
class TonWalletPrepareConfirmTransactionBloc
    extends Bloc<TonWalletPrepareConfirmTransactionEvent, TonWalletPrepareConfirmTransactionState> {
  final NekotonService _nekotonService;

  TonWalletPrepareConfirmTransactionBloc(this._nekotonService)
      : super(TonWalletPrepareConfirmTransactionStateInitial());

  @override
  Stream<TonWalletPrepareConfirmTransactionState> mapEventToState(
    TonWalletPrepareConfirmTransactionEvent event,
  ) async* {
    try {
      if (event is _PrepareConfirmTransaction) {
        final tonWallet = _nekotonService.tonWallets.firstWhereOrNull((e) => e.address == event.address);

        if (tonWallet == null) {
          throw TonWalletNotFoundException();
        }

        final message = await tonWallet.prepareConfirmTransaction(
          transactionId: event.transactionId,
          expiration: kDefaultMessageExpiration,
        );

        yield TonWalletPrepareConfirmTransactionStateSuccess(message);
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield TonWalletPrepareConfirmTransactionStateError(err);
    }
  }
}

@freezed
class TonWalletPrepareConfirmTransactionEvent with _$TonWalletPrepareConfirmTransactionEvent {
  const factory TonWalletPrepareConfirmTransactionEvent.prepareConfirmTransaction({
    required String address,
    required int transactionId,
  }) = _PrepareConfirmTransaction;
}

abstract class TonWalletPrepareConfirmTransactionState {}

class TonWalletPrepareConfirmTransactionStateInitial extends TonWalletPrepareConfirmTransactionState {}

class TonWalletPrepareConfirmTransactionStateSuccess extends TonWalletPrepareConfirmTransactionState {
  final UnsignedMessage message;

  TonWalletPrepareConfirmTransactionStateSuccess(this.message);
}

class TonWalletPrepareConfirmTransactionStateError extends TonWalletPrepareConfirmTransactionState {
  final Exception exception;

  TonWalletPrepareConfirmTransactionStateError(this.exception);
}
