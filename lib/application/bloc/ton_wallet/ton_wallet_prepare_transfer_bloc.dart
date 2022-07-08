import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:ever_wallet/application/bloc/utils.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'ton_wallet_prepare_transfer_bloc.freezed.dart';

class TonWalletPrepareTransferBloc
    extends Bloc<TonWalletPrepareTransferEvent, TonWalletPrepareTransferState> {
  final TonWalletsRepository _tonWalletsRepository;
  final String _address;

  TonWalletPrepareTransferBloc(
    this._tonWalletsRepository,
    this._address,
  ) : super(const TonWalletPrepareTransferState.initial()) {
    on<_PrepareTransfer>(
      (event, emit) async {
        emit(const TonWalletPrepareTransferState.loading());

        try {
          final repackedDestination = repackAddress(event.destination);

          final amountValue = int.parse(event.amount);

          final unsignedMessage = await _tonWalletsRepository.prepareTransfer(
            address: _address,
            publicKey: event.publicKey,
            destination: repackedDestination,
            amount: event.amount,
            body: event.body,
          );

          await unsignedMessage.refreshTimeout();

          final signature = base64.encode(List.generate(kSignatureLength, (_) => 0));

          final signedMessage = await unsignedMessage.sign(signature);

          final fees = await _tonWalletsRepository.estimateFees(
            address: _address,
            signedMessage: signedMessage,
          );
          final feesValue = int.parse(fees);

          final balance =
              await _tonWalletsRepository.getInfo(_address).then((v) => v.contractState.balance);
          final balanceValue = int.parse(balance);

          final isPossibleToSendMessage = balanceValue > (feesValue + amountValue);

          if (!isPossibleToSendMessage) throw Exception('Insufficient funds');

          emit(
            TonWalletPrepareTransferState.ready(
              unsignedMessage: unsignedMessage,
              fees: fees,
            ),
          );
        } catch (err) {
          emit(TonWalletPrepareTransferState.error(err.toString()));
        }
      },
      transformer: debounceSequential(const Duration(milliseconds: 300)),
    );
  }
}

@freezed
class TonWalletPrepareTransferEvent with _$TonWalletPrepareTransferEvent {
  const factory TonWalletPrepareTransferEvent.prepareTransfer({
    String? publicKey,
    required String destination,
    required String amount,
    String? body,
  }) = _PrepareTransfer;
}

@freezed
class TonWalletPrepareTransferState with _$TonWalletPrepareTransferState {
  const factory TonWalletPrepareTransferState.initial() = _Initial;

  const factory TonWalletPrepareTransferState.loading() = _Loading;

  const factory TonWalletPrepareTransferState.ready({
    required UnsignedMessage unsignedMessage,
    required String fees,
  }) = _Ready;

  const factory TonWalletPrepareTransferState.error(String error) = _Error;
}
