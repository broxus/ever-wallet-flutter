import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';

part 'token_wallet_info_bloc.freezed.dart';

@injectable
class TokenWalletInfoBloc extends Bloc<TokenWalletInfoEvent, TokenWalletInfoState> {
  final TokenWallet? _tokenWallet;
  final String? _logoURI;
  late final StreamSubscription _onBalanceChangedSubscription;
  late final StreamSubscription _onTransactionsFoundSubscription;
  String? _balance;
  ContractState? _contractState;

  TokenWalletInfoBloc(
    @factoryParam this._tokenWallet,
    @factoryParam this._logoURI,
  ) : super(const TokenWalletInfoState.initial()) {
    add(const TokenWalletInfoEvent.updateInfo());

    _onBalanceChangedSubscription = _tokenWallet!.onBalanceChangedStream.listen(
      (String balance) => add(
        TokenWalletInfoEvent.updateBalance(balance),
      ),
    );
    _onTransactionsFoundSubscription = _tokenWallet!.onTransactionsFoundStream.listen(
      (List<TokenWalletTransactionWithData> transactions) {
        if (transactions.isNotEmpty && transactions.last.transaction.prevTransId == null) {
          add(const TokenWalletInfoEvent.updateInfo());
        }
      },
    );
  }

  @override
  Future<void> close() {
    _onBalanceChangedSubscription.cancel();
    _onTransactionsFoundSubscription.cancel();
    return super.close();
  }

  @override
  Stream<TokenWalletInfoState> mapEventToState(TokenWalletInfoEvent event) async* {
    yield* event.when(
      updateInfo: () async* {
        try {
          final balance = await _tokenWallet!.balance;
          _balance = balance.toTokens(_tokenWallet!.symbol.decimals);
          _contractState = await _tokenWallet!.contractState;

          yield TokenWalletInfoState.ready(
            logoURI: _logoURI,
            address: _tokenWallet!.address,
            balance: _balance!,
            contractState: _contractState!,
            owner: _tokenWallet!.owner,
            symbol: _tokenWallet!.symbol,
            version: _tokenWallet!.version,
          );
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield TokenWalletInfoState.error(err.toString());
        }
      },
      updateBalance: (String balance) async* {
        try {
          _balance = balance.toTokens(_tokenWallet!.symbol.decimals);
          _contractState ??= await _tokenWallet!.contractState;

          yield TokenWalletInfoState.ready(
            logoURI: _logoURI,
            address: _tokenWallet!.address,
            balance: _balance!,
            contractState: _contractState!,
            owner: _tokenWallet!.owner,
            symbol: _tokenWallet!.symbol,
            version: _tokenWallet!.version,
          );
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield TokenWalletInfoState.error(err.toString());
        }
      },
    );
  }
}

@freezed
class TokenWalletInfoEvent with _$TokenWalletInfoEvent {
  const factory TokenWalletInfoEvent.updateInfo() = _UpdateInfo;

  const factory TokenWalletInfoEvent.updateBalance(String balance) = _UpdateBalance;
}

@freezed
class TokenWalletInfoState with _$TokenWalletInfoState {
  const factory TokenWalletInfoState.initial() = _Initial;

  const factory TokenWalletInfoState.ready({
    required String? logoURI,
    required String address,
    required String balance,
    required ContractState contractState,
    required String owner,
    required Symbol symbol,
    required TokenWalletVersion version,
  }) = _Ready;

  const factory TokenWalletInfoState.error(String info) = _Error;
}
