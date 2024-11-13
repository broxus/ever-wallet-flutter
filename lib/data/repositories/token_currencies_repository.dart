import 'dart:async';

import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/models/connection_data.dart';
import 'package:ever_wallet/data/models/currency.dart';
import 'package:ever_wallet/data/models/network_type.dart';
import 'package:ever_wallet/data/sources/local/current_accounts_source.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/data/sources/remote/http_source.dart';
import 'package:ever_wallet/data/sources/remote/transport_source.dart';
import 'package:ever_wallet/logger.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart' hide ConnectionData;
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class TokenCurrenciesRepository {
  final CurrentAccountsSource _currentAccountsSource;
  final HiveSource _hiveSource;
  final HttpSource _httpSource;
  final TransportSource _transportSource;
  late final StreamSubscription _currentAccountsStreamSubscription;

  TokenCurrenciesRepository({
    required CurrentAccountsSource currentAccountsSource,
    required HiveSource hiveSource,
    required TransportSource transportSource,
    required HttpSource httpSource,
  })  : _currentAccountsSource = currentAccountsSource,
        _hiveSource = hiveSource,
        _transportSource = transportSource,
        _httpSource = httpSource {
    _currentAccountsStreamSubscription = Rx.combineLatest3(
      _currentAccountsSource.currentAccountsStream,
      _transportSource.transportWithDataStream,
      Stream<void>.periodic(kCurrenciesRefreshTimeout).startWith(null),
      (a, t, b) => Tuple2(a, t.item2),
    ).listen((e) => _currentAccountsStreamListener(e));
  }

  /// Contains map where key - [kEverNetworkName] or [kVenomNetworkName] and value - list of currencies
  /// for the network
  Stream<Map<NetworkType, List<Currency>>> get currenciesStream =>
      Rx.combineLatest3<List<Currency>, List<Currency>, List<Currency>,
          Map<NetworkType, List<Currency>>>(
        _hiveSource.everCurrenciesStream,
        _hiveSource.venomCurrenciesStream,
        _hiveSource.tychoCurrenciesStream,
        (e, v, t) => {
          NetworkType.everscale: e,
          NetworkType.venom: v,
          NetworkType.tycho: t,
        },
      );

  /// Same as [currenciesStream]
  Map<NetworkType, List<Currency>> get currencies => {
        NetworkType.everscale: _hiveSource.everCurrencies,
        NetworkType.venom: _hiveSource.venomCurrencies,
        NetworkType.tycho: _hiveSource.tychoCurrencies,
      };

  Future<Currency?> getCurrencyForContract(String rootContract) async {
    try {
      final apiBaseUrl =
          _transportSource.transportWithData.item2.config.currenciesApiBaseUrl;
      final currency = await _httpSource.getCurrency(apiBaseUrl, rootContract);

      return currency;
    } catch (e, st) {
      logger.e('getCurrencyForContract', e, st);
      return null;
    }
  }

  Future<void> clear() => _hiveSource.clearCurrencies();

  Future<void> dispose() => _currentAccountsStreamSubscription.cancel();

  Future<void> _currentAccountsStreamListener(
    Tuple2<List<AssetsList>, ConnectionData> event,
  ) async {
    try {
      final currentAccounts = event.item1;
      final data = event.item2;

      final rootTokenContracts = [
        ...{
          data.type.when(
            everscale: () => kAddressForEverCurrency,
            venom: () => kAddressForVenomCurrency,
            tycho: () => kAddressForTychoCurrency,
          ),
          ...currentAccounts
              .map((e) => e.additionalAssets.values
                  .map((e) => e.tokenWallets)
                  .expand((e) => e))
              .expand((e) => e)
              .map((e) => e.rootTokenContract),
        }
      ];

      for (final rootTokenContract in rootTokenContracts) {
        try {
          final apiBaseUrl = data.config.currenciesApiBaseUrl;
          final currency =
              await _httpSource.getCurrency(apiBaseUrl, rootTokenContract);

          switch (data.type) {
            case NetworkType.everscale:
              return await _hiveSource.saveEverCurrency(
                address: rootTokenContract,
                currency: currency,
              );
            case NetworkType.venom:
              return await _hiveSource.saveVenomCurrency(
                address: rootTokenContract,
                currency: currency,
              );
            case NetworkType.tycho:
              return await _hiveSource.saveTychoCurrency(
                address: rootTokenContract,
                currency: currency,
              );
          }
        } catch (err) {
          // logger.e(err, err, st);
        }
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
