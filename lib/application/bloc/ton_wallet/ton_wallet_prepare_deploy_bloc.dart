import 'package:bloc/bloc.dart';
import 'package:ever_wallet/application/bloc/utils.dart';
import 'package:ever_wallet/data/models/unsigned_message_with_additional_info.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ton_wallet_prepare_deploy_bloc.freezed.dart';

class TonWalletPrepareDeployBloc
    extends Bloc<TonWalletPrepareDeployEvent, TonWalletPrepareDeployState> {
  final TonWalletsRepository _tonWalletsRepository;
  final String _address;

  TonWalletPrepareDeployBloc(
    this._tonWalletsRepository,
    this._address,
  ) : super(const TonWalletPrepareDeployState.initial()) {
    on<_PrepareDeploy>(
      (event, emit) async {
        emit(const TonWalletPrepareDeployState.loading());

        try {
          late final UnsignedMessageWithAdditionalInfo unsignedMessage;

          if (event.custodians != null && event.reqConfirms != null) {
            unsignedMessage =
                await _tonWalletsRepository.prepareDeployWithMultipleOwners(
              address: _address,
              custodians: event.custodians!,
              reqConfirms: event.reqConfirms!,
            );
          } else {
            unsignedMessage =
                await _tonWalletsRepository.prepareDeploy(_address);
          }

          final fees = await _tonWalletsRepository.estimateFees(
            address: _address,
            message: unsignedMessage.message,
          );
          final feesValue = int.parse(fees);

          final balance = await _tonWalletsRepository
              .contractState(_address)
              .then((value) => value.balance);
          final balanceValue = int.parse(balance);

          final isPossibleToSendMessage = balanceValue > feesValue;

          if (!isPossibleToSendMessage) throw Exception('Insufficient funds');

          emit(
            TonWalletPrepareDeployState.ready(
              unsignedMessage: unsignedMessage,
              fees: fees,
            ),
          );
        } catch (err) {
          emit(TonWalletPrepareDeployState.error(err.toString()));
        }
      },
      transformer: debounceSequential(const Duration(milliseconds: 300)),
    );
  }
}

@freezed
class TonWalletPrepareDeployEvent with _$TonWalletPrepareDeployEvent {
  const factory TonWalletPrepareDeployEvent.prepareDeploy({
    List<String>? custodians,
    int? reqConfirms,
  }) = _PrepareDeploy;
}

@freezed
class TonWalletPrepareDeployState with _$TonWalletPrepareDeployState {
  const factory TonWalletPrepareDeployState.initial() = _Initial;

  const factory TonWalletPrepareDeployState.loading() = _Loading;

  const factory TonWalletPrepareDeployState.ready({
    required UnsignedMessageWithAdditionalInfo unsignedMessage,
    required String fees,
  }) = _Ready;

  const factory TonWalletPrepareDeployState.error(String error) = _Error;
}
