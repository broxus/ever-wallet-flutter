import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../repositories/ton_assets_repository.dart';
import '../../services/nekoton_service.dart';

part 'token_wallet_info_bloc.freezed.dart';

@injectable
class TokenWalletInfoBloc extends Bloc<TokenWalletInfoEvent, TokenWalletInfoState> {
  final NekotonService _nekotonService;
  final TonAssetsRepository _tonAssetsRepository;
  final String? _owner;
  final String? _rootTokenContract;
  StreamSubscription? _onBalanceChangedSubscription;
  StreamSubscription? _onTransactionsFoundSubscription;
  String? _logoURI;
  String? _balance;
  ContractState? _contractState;

  TokenWalletInfoBloc(
    this._nekotonService,
    this._tonAssetsRepository,
    @factoryParam this._owner,
    @factoryParam this._rootTokenContract,
  ) : super(const TokenWalletInfoState.initial()) {
    _nekotonService.tokenWalletsStream
        .expand((e) => e)
        .firstWhere((e) => e.owner == _owner! && e.symbol.rootTokenContract == _rootTokenContract!)
        .then((value) {
      add(const TokenWalletInfoEvent.updateInfo());

      _onBalanceChangedSubscription = value.onBalanceChangedStream.listen(
        (String balance) => add(
          TokenWalletInfoEvent.updateBalance(balance),
        ),
      );
      _onTransactionsFoundSubscription = value.onTransactionsFoundStream.listen(
        (List<TokenWalletTransactionWithData> transactions) {
          if (transactions.isNotEmpty && transactions.last.transaction.prevTransId == null) {
            add(const TokenWalletInfoEvent.updateInfo());
          }
        },
      );
    });
  }

  @override
  Future<void> close() {
    _onBalanceChangedSubscription?.cancel();
    _onTransactionsFoundSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<TokenWalletInfoState> mapEventToState(TokenWalletInfoEvent event) async* {
    yield* event.when(
      updateInfo: () async* {
        try {
          final tokenWallet = _nekotonService.tokenWallets
              .firstWhere((e) => e.owner == _owner! && e.symbol.rootTokenContract == _rootTokenContract!);

          final balance = await tokenWallet.balance;
          _balance = balance.toTokens(tokenWallet.symbol.decimals);
          _contractState = await tokenWallet.contractState;
          _logoURI ??= await _tonAssetsRepository.getTokenLogoUri(tokenWallet.symbol.rootTokenContract);

          yield TokenWalletInfoState.ready(
            logoURI: _logoURI,
            address: tokenWallet.address,
            balance: _balance!,
            contractState: _contractState!,
            owner: tokenWallet.owner,
            symbol: tokenWallet.symbol,
            version: tokenWallet.version,
            ownerPublicKey: tokenWallet.ownerPublicKey,
          );
        } on Exception catch (err, st) {
          logger.e(err, err, st);
          yield TokenWalletInfoState.error(err.toString());
        }
      },
      updateBalance: (String balance) async* {
        try {
          final tokenWallet = _nekotonService.tokenWallets
              .firstWhere((e) => e.owner == _owner! && e.symbol.rootTokenContract == _rootTokenContract!);

          _balance = balance.toTokens(tokenWallet.symbol.decimals);
          _contractState ??= await tokenWallet.contractState;
          _logoURI ??= await _tonAssetsRepository.getTokenLogoUri(tokenWallet.symbol.rootTokenContract);

          yield TokenWalletInfoState.ready(
            logoURI: _logoURI,
            address: tokenWallet.address,
            balance: _balance!,
            contractState: _contractState!,
            owner: tokenWallet.owner,
            symbol: tokenWallet.symbol,
            version: tokenWallet.version,
            ownerPublicKey: tokenWallet.ownerPublicKey,
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
    String? logoURI,
    required String address,
    required String balance,
    required ContractState contractState,
    required String owner,
    required Symbol symbol,
    required TokenWalletVersion version,
    required String ownerPublicKey,
  }) = _Ready;

  const factory TokenWalletInfoState.error(String info) = _Error;
}
