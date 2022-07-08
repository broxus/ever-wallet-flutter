import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/models/currency.dart';
import 'package:ever_wallet/data/models/token_wallet_info.dart';
import 'package:ever_wallet/data/models/ton_wallet_info.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/data/repositories/token_currencies_repository.dart';
import 'package:ever_wallet/data/repositories/token_wallets_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

Stream<double> accountOverallBalanceStream(
  AccountsRepository accountsRepository,
  TransportRepository transportRepository,
  TonWalletsRepository tonWalletsRepository,
  TokenWalletsRepository tokenWalletsRepository,
  TokenCurrenciesRepository tokenCurrenciesRepository,
  String address,
) =>
    Rx.combineLatest2<AssetsList, Transport, Tuple2<AssetsList, Transport>>(
      accountsRepository.accountsStream.expand((e) => e).where((e) => e.address == address),
      transportRepository.transportStream,
      (a, b) => Tuple2(a, b),
    ).flatMap((v) {
      final account = v.item1;
      final transport = v.item2;

      final tokenWallets = account.additionalAssets[transport.group]?.tokenWallets
              .map((e) => e.rootTokenContract)
              .toList() ??
          [];

      final tonWalletBalanceStream = Rx.combineLatest2<TonWalletInfo?, Currency?, double>(
        tonWalletsRepository.getInfoStream(account.address),
        tokenCurrenciesRepository.currenciesStream
            .expand((e) => e)
            .where((e) => e.address == kAddressForEverCurrency)
            .cast<Currency?>()
            .onErrorReturn(null)
            .startWith(null),
        (a, b) => a != null && b != null
            ? double.parse(a.contractState.balance.toTokens()) * double.parse(b.price)
            : 0,
      );

      final tokenWalletBalancesStream = tokenWallets.map(
        (e) => Rx.combineLatest2<TokenWalletInfo?, Currency?, double>(
          tokenWalletsRepository.getInfoStream(
            owner: account.address,
            rootTokenContract: e,
          ),
          tokenCurrenciesRepository.currenciesStream
              .expand((e) => e)
              .where((el) => el.address == e)
              .cast<Currency?>()
              .onErrorReturn(null)
              .startWith(null),
          (a, b) => a != null && b != null
              ? double.parse(a.balance.toTokens(a.symbol.decimals)) * double.parse(b.price)
              : 0,
        ),
      );

      return Rx.combineLatestList<double>([tonWalletBalanceStream, ...tokenWalletBalancesStream]);
    }).map((e) => e.fold<double>(0, (p, c) => p + c));
