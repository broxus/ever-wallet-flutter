import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:ever_wallet/application/bloc/utils.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'ton_wallet_prepare_confirm_transaction_bloc.freezed.dart';

class TonWalletPrepareConfirmTransactionBloc
    extends Bloc<TonWalletPrepareConfirmTransactionEvent, TonWalletPrepareConfirmTransactionState> {
  final TonWalletsRepository _tonWalletsRepository;
  final String _address;

  TonWalletPrepareConfirmTransactionBloc(
    this._tonWalletsRepository,
    this._address,
  ) : super(const TonWalletPrepareConfirmTransactionState.initial()) {
    on<_PrepareConfirmTransaction>(
      (event, emit) async {
        emit(const TonWalletPrepareConfirmTransactionState.loading());

        try {
          final unsignedMessage = await _tonWalletsRepository.prepareConfirmTransaction(
            address: _address,
            publicKey: event.publicKey,
            transactionId: event.transactionId,
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

          final isPossibleToSendMessage = balanceValue > feesValue;

          if (!isPossibleToSendMessage) throw Exception('Insufficient funds');

          emit(
            TonWalletPrepareConfirmTransactionState.ready(
              unsignedMessage: unsignedMessage,
              fees: fees,
            ),
          );
        } catch (err) {
          emit(TonWalletPrepareConfirmTransactionState.error(err.toString()));
        }
      },
      transformer: debounceSequential(const Duration(milliseconds: 300)),
    );
  }
}

@freezed
class TonWalletPrepareConfirmTransactionEvent with _$TonWalletPrepareConfirmTransactionEvent {
  const factory TonWalletPrepareConfirmTransactionEvent.prepareConfirmTransaction({
    required String publicKey,
    required String transactionId,
  }) = _PrepareConfirmTransaction;
}

@freezed
class TonWalletPrepareConfirmTransactionState with _$TonWalletPrepareConfirmTransactionState {
  const factory TonWalletPrepareConfirmTransactionState.initial() = _Initial;

  const factory TonWalletPrepareConfirmTransactionState.loading() = _Loading;

  const factory TonWalletPrepareConfirmTransactionState.ready({
    required UnsignedMessage unsignedMessage,
    required String fees,
  }) = _Ready;

  const factory TonWalletPrepareConfirmTransactionState.error(String error) = _Error;
}
