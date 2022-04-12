import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../injection.dart';
import '../../data/constants.dart';
import '../../data/models/currency.dart';
import '../../data/models/token_wallet_info.dart';
import '../../data/models/ton_wallet_info.dart';
import '../../data/repositories/accounts_repository.dart';
import '../../data/repositories/token_currencies_repository.dart';
import '../../data/repositories/token_wallets_repository.dart';
import '../../data/repositories/ton_wallets_repository.dart';
import '../../data/repositories/transport_repository.dart';
import '../../presentation/common/extensions.dart';

final accountOverallBalanceProvider = StreamProvider.autoDispose.family<double, String>(
  (ref, address) => Rx.combineLatest2<AssetsList, Transport, Tuple2<AssetsList, Transport>>(
    getIt.get<AccountsRepository>().accountsStream.expand((e) => e).where((e) => e.address == address),
    getIt.get<TransportRepository>().transportStream,
    (a, b) => Tuple2(a, b),
  ).flatMap((v) {
    final account = v.item1;
    final transport = v.item2;

    final tokenWallets = account.additionalAssets[transport.connectionData.group]?.tokenWallets
            .map((e) => e.rootTokenContract)
            .toList() ??
        [];

    final tonWalletBalanceStream = Rx.combineLatest2<TonWalletInfo?, Currency?, double>(
      getIt.get<TonWalletsRepository>().getInfoStream(account.address),
      getIt
          .get<TokenCurrenciesRepository>()
          .currenciesStream
          .expand((e) => e)
          .where((e) => e.address == kAddressForEverCurrency)
          .cast<Currency?>()
          .onErrorReturn(null)
          .startWith(null),
      (a, b) => a != null && b != null ? double.parse(a.contractState.balance.toTokens()) * double.parse(b.price) : 0,
    );

    final tokenWalletBalancesStream = tokenWallets.map(
      (e) => Rx.combineLatest2<TokenWalletInfo?, Currency?, double>(
        getIt.get<TokenWalletsRepository>().getInfoStream(
              owner: account.address,
              rootTokenContract: e,
            ),
        getIt
            .get<TokenCurrenciesRepository>()
            .currenciesStream
            .expand((e) => e)
            .where((el) => el.address == e)
            .cast<Currency?>()
            .onErrorReturn(null)
            .startWith(null),
        (a, b) =>
            a != null && b != null ? double.parse(a.balance.toTokens(a.symbol.decimals)) * double.parse(b.price) : 0,
      ),
    );

    return Rx.combineLatestList<double>([tonWalletBalanceStream, ...tokenWalletBalancesStream]);
  }).map((e) => e.fold<double>(0, (p, c) => p + c)),
);
