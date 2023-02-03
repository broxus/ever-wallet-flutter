import 'package:bloc/bloc.dart';
import 'package:ever_wallet/application/bloc/utils.dart';
import 'package:ever_wallet/data/models/signed_message_with_additional_info.dart';
import 'package:ever_wallet/data/models/unsigned_message_with_additional_info.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'ton_wallet_send_bloc.freezed.dart';

class TonWalletSendBloc extends Bloc<TonWalletSendEvent, TonWalletSendState> {
  final TonWalletsRepository _tonWalletsRepository;
  final KeysRepository _keysRepository;
  final String _address;

  TonWalletSendBloc(
    this._tonWalletsRepository,
    this._keysRepository,
    this._address,
  ) : super(const TonWalletSendState.initial()) {
    on<_Send>(
      (event, emit) async {
        emit(const TonWalletSendState.loading());

        try {
          await event.unsignedMessage.message.refreshTimeout();

          final hash = event.unsignedMessage.message.hash;
          final transport =
              (await _tonWalletsRepository.getTonWalletStream(_address).first).transport;

          final signature = await _keysRepository.sign(
            data: hash,
            publicKey: event.publicKey,
            password: event.password,
            signatureId: await transport.getSignatureId(),
          );

          final signedMessage = await event.unsignedMessage.message.sign(signature);

          final signedMessageWithAdditionalInfo = SignedMessageWithAdditionalInfo(
            message: signedMessage,
            dst: event.unsignedMessage.dst,
            amount: event.unsignedMessage.amount,
          );

          final transaction = await _tonWalletsRepository.send(
            address: _address,
            signedMessageWithAdditionalInfo: signedMessageWithAdditionalInfo,
          );

          emit(TonWalletSendState.ready(transaction));
        } catch (err) {
          emit(TonWalletSendState.error(err.toString()));
        }
      },
      transformer: debounceSequential(const Duration(milliseconds: 300)),
    );
  }
}

@freezed
class TonWalletSendEvent with _$TonWalletSendEvent {
  const factory TonWalletSendEvent.send({
    required UnsignedMessageWithAdditionalInfo unsignedMessage,
    required String publicKey,
    required String password,
  }) = _Send;
}

@freezed
class TonWalletSendState with _$TonWalletSendState {
  const factory TonWalletSendState.initial() = _Initial;

  const factory TonWalletSendState.loading() = _Loading;

  const factory TonWalletSendState.ready(Transaction transaction) = _Ready;

  const factory TonWalletSendState.error(String error) = _Error;
}
