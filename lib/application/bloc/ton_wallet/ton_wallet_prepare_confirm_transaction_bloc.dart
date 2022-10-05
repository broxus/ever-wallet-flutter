import 'package:bloc/bloc.dart';
import 'package:ever_wallet/application/bloc/utils.dart';
import 'package:ever_wallet/data/models/unsigned_message_with_additional_info.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

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

          final fees = await _tonWalletsRepository.estimateFees(
            address: _address,
            unsignedMessageWithAdditionalInfo: unsignedMessage,
          );
          final feesValue = int.parse(fees);

          final balance =
              await _tonWalletsRepository.contractState(_address).then((value) => value.balance);
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
    required UnsignedMessageWithAdditionalInfo unsignedMessage,
    required String fees,
  }) = _Ready;

  const factory TonWalletPrepareConfirmTransactionState.error(String error) = _Error;
}
