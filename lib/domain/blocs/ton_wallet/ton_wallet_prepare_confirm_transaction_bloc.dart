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
      : super(const TonWalletPrepareConfirmTransactionState.initial());

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
          publicKey: event.publicKey,
          transactionId: event.transactionId,
          expiration: kDefaultMessageExpiration,
        );

        yield TonWalletPrepareConfirmTransactionState.success(message);
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield TonWalletPrepareConfirmTransactionState.error(err);
    }
  }
}

@freezed
class TonWalletPrepareConfirmTransactionEvent with _$TonWalletPrepareConfirmTransactionEvent {
  const factory TonWalletPrepareConfirmTransactionEvent.prepareConfirmTransaction({
    required String publicKey,
    required String address,
    required String transactionId,
  }) = _PrepareConfirmTransaction;
}

@freezed
class TonWalletPrepareConfirmTransactionState with _$TonWalletPrepareConfirmTransactionState {
  const factory TonWalletPrepareConfirmTransactionState.initial() = _Initial;

  const factory TonWalletPrepareConfirmTransactionState.success(UnsignedMessage message) = _Success;

  const factory TonWalletPrepareConfirmTransactionState.error(Exception exception) = _Error;

  const TonWalletPrepareConfirmTransactionState._();

  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => 0;
}
