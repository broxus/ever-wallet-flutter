import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'ton_wallet_prepare_transfer_bloc.freezed.dart';

@injectable
class TonWalletPrepareTransferBloc extends Bloc<TonWalletPrepareTransferEvent, TonWalletPrepareTransferState> {
  final NekotonService _nekotonService;

  TonWalletPrepareTransferBloc(this._nekotonService) : super(TonWalletPrepareTransferStateInitial());

  @override
  Stream<TonWalletPrepareTransferState> mapEventToState(TonWalletPrepareTransferEvent event) async* {
    try {
      if (event is _PrepareTransfer) {
        final tonWallet = _nekotonService.tonWallets.firstWhereOrNull((e) => e.address == event.address);

        if (tonWallet == null) {
          throw TonWalletNotFoundException();
        }

        final repackedDestination = repackAddress(event.destination);

        final amountValue = int.parse(event.amount);

        final message = await tonWallet.prepareTransfer(
          expiration: kDefaultMessageExpiration,
          destination: repackedDestination,
          amount: amountValue,
          body: event.comment,
        );

        yield TonWalletPrepareTransferStateSuccess(message);
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield TonWalletPrepareTransferStateError(err);
    }
  }
}

@freezed
class TonWalletPrepareTransferEvent with _$TonWalletPrepareTransferEvent {
  const factory TonWalletPrepareTransferEvent.prepareTransfer({
    required String address,
    required String destination,
    required String amount,
    String? comment,
  }) = _PrepareTransfer;
}

abstract class TonWalletPrepareTransferState {}

class TonWalletPrepareTransferStateInitial extends TonWalletPrepareTransferState {}

class TonWalletPrepareTransferStateSuccess extends TonWalletPrepareTransferState {
  final UnsignedMessage message;

  TonWalletPrepareTransferStateSuccess(this.message);
}

class TonWalletPrepareTransferStateError extends TonWalletPrepareTransferState {
  final Exception exception;

  TonWalletPrepareTransferStateError(this.exception);
}
