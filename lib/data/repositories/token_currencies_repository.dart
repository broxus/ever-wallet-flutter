import 'dart:async';

import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/models/currency.dart';
import 'package:ever_wallet/data/sources/local/current_accounts_source.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/data/sources/remote/http_source.dart';
import 'package:ever_wallet/data/sources/remote/transport_source.dart';
import 'package:ever_wallet/logger.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
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
    _currentAccountsStreamSubscription =
        Rx.combineLatest3<List<AssetsList>, Transport, void, Tuple2<List<AssetsList>, Transport>>(
      _currentAccountsSource.currentAccountsStream,
      _transportSource.transportStream,
      Stream<void>.periodic(kCurrenciesRefreshTimeout).startWith(null),
      (a, t, b) => Tuple2(a, t),
    ).listen((e) => _currentAccountsStreamListener(e));
  }

  /// Contains map where key - [kEverNetworkName] or [kVenomNetworkName] and value - list of currencies
  /// for the network
  Stream<Map<String, List<Currency>>> get currenciesStream =>
      Rx.combineLatest2<List<Currency>, List<Currency>, Map<String, List<Currency>>>(
        _hiveSource.everCurrenciesStream,
        _hiveSource.venomCurrenciesStream,
        (e, v) => {kEverNetworkName: e, kVenomNetworkName: v},
      );

  /// Same as [currenciesStream]
  Map<String, List<Currency>> get currencies => {
        kEverNetworkName: _hiveSource.everCurrencies,
        kVenomNetworkName: _hiveSource.venomCurrencies,
      };

  Future<void> clear() => _hiveSource.clearCurrencies();

  Future<void> dispose() => _currentAccountsStreamSubscription.cancel();

  Future<void> _currentAccountsStreamListener(Tuple2<List<AssetsList>, Transport> event) async {
    try {
      final currentAccounts = event.item1;
      final transport = event.item2;

      final isEver = !transport.name.contains('Venom');

      final rootTokenContracts = [
        ...{
          if (isEver) kAddressForEverCurrency else kAddressForVenomCurrency,
          ...currentAccounts
              .map((e) => e.additionalAssets.values.map((e) => e.tokenWallets).expand((e) => e))
              .expand((e) => e)
              .map((e) => e.rootTokenContract),
        }
      ];

      for (final rootTokenContract in rootTokenContracts) {
        try {
          final currency = isEver
              ? await _httpSource.getEverCurrency(rootTokenContract)
              : await _httpSource.getVenomCurrency(rootTokenContract);

          isEver
              ? await _hiveSource.saveEverCurrency(
                  address: rootTokenContract,
                  currency: currency,
                )
              : await _hiveSource.saveVenomCurrency(
                  address: rootTokenContract,
                  currency: currency,
                );
        } catch (err) {
          // logger.e(err, err, st);
        }
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
