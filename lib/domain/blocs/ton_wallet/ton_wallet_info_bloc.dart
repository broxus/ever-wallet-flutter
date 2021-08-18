import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';

part 'ton_wallet_info_bloc.freezed.dart';

@injectable
class TonWalletInfoBloc extends Bloc<TonWalletInfoEvent, TonWalletInfoState> {
  final TonWallet? _tonWallet;
  late final StreamSubscription _onStateChangedSubscription;
  ContractState? _contractState;

  TonWalletInfoBloc(@factoryParam this._tonWallet) : super(const TonWalletInfoState.initial()) {
    add(const TonWalletInfoEvent.updateInfo());

    _onStateChangedSubscription = _tonWallet!.onStateChangedStream.listen(
      (ContractState contractState) => add(
        TonWalletInfoEvent.updateState(contractState),
      ),
    );
  }

  @override
  Future<void> close() {
    _onStateChangedSubscription.cancel();
    return super.close();
  }

  @override
  Stream<TonWalletInfoState> mapEventToState(TonWalletInfoEvent event) async* {
    if (event is TonWalletInfoEvent) {
      yield* event.when(
        updateInfo: () async* {
          try {
            final contractState = await _tonWallet!.contractState;
            final balance = contractState.balance.toTokens();
            _contractState = contractState.copyWith(balance: balance);

            yield TonWalletInfoState.ready(
              address: _tonWallet!.address,
              contractState: _contractState!,
              walletType: _tonWallet!.walletType,
              details: _tonWallet!.details,
              publicKey: _tonWallet!.publicKey,
            );
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield TonWalletInfoState.error(err.toString());
          }
        },
        updateState: (ContractState contractState) async* {
          try {
            final balance = contractState.balance.toTokens();
            _contractState = contractState.copyWith(balance: balance);

            yield TonWalletInfoState.ready(
              address: _tonWallet!.address,
              contractState: _contractState!,
              walletType: _tonWallet!.walletType,
              details: _tonWallet!.details,
              publicKey: _tonWallet!.publicKey,
            );
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield TonWalletInfoState.error(err.toString());
          }
        },
      );
    }
  }
}

@freezed
class TonWalletInfoEvent with _$TonWalletInfoEvent {
  const factory TonWalletInfoEvent.updateInfo() = _UpdateInfo;

  const factory TonWalletInfoEvent.updateState(ContractState contractState) = _UpdateState;
}

@freezed
class TonWalletInfoState with _$TonWalletInfoState {
  const factory TonWalletInfoState.initial() = _Initial;

  const factory TonWalletInfoState.ready({
    required String address,
    required ContractState contractState,
    required WalletType walletType,
    required TonWalletDetails details,
    required String publicKey,
  }) = _Ready;

  const factory TonWalletInfoState.error(String info) = _Error;
}
