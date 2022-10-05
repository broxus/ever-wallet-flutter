import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/models/currency.dart';
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
    Rx.combineLatest2<Transport, AssetsList, Tuple2<Transport, AssetsList>>(
      transportRepository.transportStream,
      accountsRepository.accountsStream.expand((e) => e).where((e) => e.address == address),
      (a, b) => Tuple2(a, b),
    ).flatMap((v) {
      final transport = v.item1;
      final account = v.item2;

      final tokenWallets = account.additionalAssets[transport.group]?.tokenWallets
              .map((e) => e.rootTokenContract)
              .toList() ??
          [];

      final tonWalletBalanceStream = Rx.combineLatest2<String, Currency?, double>(
        tonWalletsRepository.contractStateStream(account.address).map((e) => e.balance),
        tokenCurrenciesRepository.currenciesStream
            .expand((e) => e)
            .where((e) => e.address == kAddressForEverCurrency)
            .cast<Currency?>()
            .onErrorReturn(null)
            .startWith(null),
        (a, b) => b != null ? double.parse(a.toTokens()) * double.parse(b.price) : 0,
      );

      final tokenWalletBalancesStream = tokenWallets.map(
        (e) => Rx.combineLatest3<String, Symbol, Currency?, double>(
          tokenWalletsRepository.balanceStream(
            owner: account.address,
            rootTokenContract: e,
          ),
          tokenWalletsRepository.symbolStream(
            owner: account.address,
            rootTokenContract: e,
          ),
          tokenCurrenciesRepository.currenciesStream
              .expand((e) => e)
              .where((el) => el.address == e)
              .cast<Currency?>()
              .onErrorReturn(null)
              .startWith(null),
          (a, b, c) => c != null ? double.parse(a.toTokens(b.decimals)) * double.parse(c.price) : 0,
        ),
      );

      return Rx.combineLatestList<double>([tonWalletBalanceStream, ...tokenWalletBalancesStream]);
    }).map((e) => e.fold<double>(0, (p, c) => p + c));
