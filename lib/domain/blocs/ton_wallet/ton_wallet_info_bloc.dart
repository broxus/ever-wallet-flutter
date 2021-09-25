import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'ton_wallet_info_bloc.freezed.dart';

@injectable
class TonWalletInfoBloc extends Bloc<TonWalletInfoEvent, TonWalletInfoState> {
  final NekotonService _nekotonService;
  final String? _address;
  StreamSubscription? _onStateChangedSubscription;
  ContractState? _contractState;

  TonWalletInfoBloc(
    this._nekotonService,
    @factoryParam this._address,
  ) : super(const TonWalletInfoState.initial()) {
    _nekotonService.tonWalletsStream.expand((e) => e).firstWhere((e) => e.address == _address!).then((value) {
      add(const TonWalletInfoEvent.updateInfo());

      _onStateChangedSubscription = value.onStateChangedStream.listen(
        (ContractState contractState) => add(
          TonWalletInfoEvent.updateState(contractState),
        ),
      );
    });
  }

  @override
  Future<void> close() {
    _onStateChangedSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<TonWalletInfoState> mapEventToState(TonWalletInfoEvent event) async* {
    if (event is TonWalletInfoEvent) {
      yield* event.when(
        updateInfo: () async* {
          try {
            final tonWallet = _nekotonService.tonWallets.firstWhere((e) => e.address == _address!);

            final contractState = await tonWallet.contractState;
            final balance = contractState.balance.toTokens();
            _contractState = contractState.copyWith(balance: balance);

            yield TonWalletInfoState.ready(
              address: tonWallet.address,
              contractState: _contractState!,
              walletType: tonWallet.walletType,
              details: tonWallet.details,
              publicKey: tonWallet.publicKey,
            );
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield TonWalletInfoState.error(err.toString());
          }
        },
        updateState: (ContractState contractState) async* {
          try {
            final tonWallet = _nekotonService.tonWallets.firstWhere((e) => e.address == _address!);

            final balance = contractState.balance.toTokens();
            _contractState = contractState.copyWith(balance: balance);

            yield TonWalletInfoState.ready(
              address: tonWallet.address,
              contractState: _contractState!,
              walletType: tonWallet.walletType,
              details: tonWallet.details,
              publicKey: tonWallet.publicKey,
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
