import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';

part 'ton_wallet_prepare_transfer_bloc.freezed.dart';

@injectable
class TonWalletPrepareTransferBloc extends Bloc<TonWalletPrepareTransferEvent, TonWalletPrepareTransferState> {
  final NekotonService _nekotonService;

  TonWalletPrepareTransferBloc(this._nekotonService) : super(const TonWalletPrepareTransferState.initial());

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
          publicKey: event.publicKey,
          destination: repackedDestination,
          amount: amountValue,
          body: event.body,
          isComment: event.isComment,
          expiration: kDefaultMessageExpiration,
        );

        yield TonWalletPrepareTransferState.success(message);
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield TonWalletPrepareTransferState.error(err);
    }
  }
}

@freezed
class TonWalletPrepareTransferEvent with _$TonWalletPrepareTransferEvent {
  const factory TonWalletPrepareTransferEvent.prepareTransfer({
    required String address,
    required String publicKey,
    required String destination,
    required String amount,
    String? body,
    @Default(true) bool isComment,
  }) = _PrepareTransfer;
}

@freezed
class TonWalletPrepareTransferState with _$TonWalletPrepareTransferState {
  const factory TonWalletPrepareTransferState.initial() = _Initial;

  const factory TonWalletPrepareTransferState.success(UnsignedMessage message) = _Success;

  const factory TonWalletPrepareTransferState.error(Exception exception) = _Error;

  const TonWalletPrepareTransferState._();

  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => 0;
}
