import 'package:bloc/bloc.dart';
import 'package:ever_wallet/application/bloc/utils.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/models/unsigned_message_with_additional_info.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/logger.dart';
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
            bounce: kMessageBounce,
          );

          final fees = await _tonWalletsRepository.estimateFees(
            address: _address,
            unsignedMessageWithAdditionalInfo: unsignedMessage,
          );
          final feesValue = int.parse(fees);

          final txErrors = await _tonWalletsRepository.simulateTransactionTree(
            address: _address,
            message: unsignedMessage.message,
          );

          final balance = await _tonWalletsRepository
              .contractState(_address)
              .then((value) => value.balance);
          final balanceValue = int.parse(balance);

          final isPossibleToSendMessage =
              balanceValue > (feesValue + amountValue);

          if (!isPossibleToSendMessage) throw Exception('Insufficient funds');

          emit(
            TonWalletPrepareTransferState.ready(
              unsignedMessage: unsignedMessage,
              fees: fees,
              txErrors: txErrors,
            ),
          );
        } catch (err, t) {
          logger.e('Sending EVER', err, t);
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
    required String publicKey,
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
    required UnsignedMessageWithAdditionalInfo unsignedMessage,
    required String fees,
    required List<TxTreeSimulationErrorItem> txErrors,
  }) = _Ready;

  const factory TonWalletPrepareTransferState.error(String error) = _Error;
}
