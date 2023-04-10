import 'package:bloc/bloc.dart';
import 'package:ever_wallet/application/bloc/utils.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/models/unsigned_message_with_additional_info.dart';
import 'package:ever_wallet/data/repositories/token_wallets_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'token_wallet_prepare_transfer_bloc.freezed.dart';

class TokenWalletPrepareTransferBloc
    extends Bloc<TokenWalletPrepareTransferEvent, TokenWalletPrepareTransferState> {
  final TokenWalletsRepository _tokenWalletsRepository;
  final TonWalletsRepository _tonWalletsRepository;
  final String _owner;
  final String _rootTokenContract;

  /// Amount of EVERS we want to attach to transaction (in nano-tokens)
  final String? _attachedAmount;

  TokenWalletPrepareTransferBloc(
    this._tokenWalletsRepository,
    this._tonWalletsRepository,
    this._owner,
    this._rootTokenContract,
    this._attachedAmount,
  ) : super(const TokenWalletPrepareTransferState.initial()) {
    on<_PrepareTransfer>(
      (event, emit) async {
        emit(const TokenWalletPrepareTransferState.loading());

        try {
          final repackedDestination = repackAddress(event.destination);

          final internalMessage = await _tokenWalletsRepository.prepareTransfer(
            owner: _owner,
            rootTokenContract: _rootTokenContract,
            destination: repackedDestination,
            tokens: event.amount,
            notifyReceiver: event.notifyReceiver,
            payload: event.payload,
          );

          final amountValue =
              BigInt.parse(internalMessage.amount) + BigInt.parse(_attachedAmount ?? '0');

          final unsignedMessage = await _tonWalletsRepository.prepareTransfer(
            address: _owner,
            publicKey: event.publicKey,
            destination: internalMessage.destination,
            amount: amountValue.toString(),
            body: internalMessage.body,
            bounce: kMessageBounce,
          );

          final fees = await _tonWalletsRepository.estimateFees(
            address: _owner,
            unsignedMessageWithAdditionalInfo: unsignedMessage,
          );
          final feesValue = BigInt.parse(fees);

          final balance =
              await _tonWalletsRepository.contractState(_owner).then((value) => value.balance);
          final balanceValue = BigInt.parse(balance);

          final isPossibleToSendMessage = balanceValue > (feesValue + amountValue);

          if (!isPossibleToSendMessage) throw Exception('Insufficient funds');

          emit(
            TokenWalletPrepareTransferState.ready(
              unsignedMessage: unsignedMessage,
              fees: fees,
            ),
          );
        } catch (err, t) {
          logger.e('Sending TOKEN', err, t);
          emit(TokenWalletPrepareTransferState.error(err.toString()));
        }
      },
      transformer: debounceSequential(const Duration(milliseconds: 300)),
    );
  }
}

@freezed
class TokenWalletPrepareTransferEvent with _$TokenWalletPrepareTransferEvent {
  const factory TokenWalletPrepareTransferEvent.prepareTransfer({
    required String publicKey,
    required String destination,
    required String amount,
    required bool notifyReceiver,
    String? payload,
  }) = _PrepareTransfer;
}

@freezed
class TokenWalletPrepareTransferState with _$TokenWalletPrepareTransferState {
  const factory TokenWalletPrepareTransferState.initial() = _Initial;

  const factory TokenWalletPrepareTransferState.loading() = _Loading;

  const factory TokenWalletPrepareTransferState.ready({
    required UnsignedMessageWithAdditionalInfo unsignedMessage,
    required String fees,
  }) = _Ready;

  const factory TokenWalletPrepareTransferState.error(String error) = _Error;
}
