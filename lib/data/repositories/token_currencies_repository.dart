import 'dart:async';

import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/models/currency.dart';
import 'package:ever_wallet/data/sources/local/current_accounts_source.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/data/sources/remote/http_source.dart';
import 'package:ever_wallet/logger.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

class TokenCurrenciesRepository {
  final CurrentAccountsSource _currentAccountsSource;
  final HiveSource _hiveSource;
  final HttpSource _httpSource;
  late final StreamSubscription _currentAccountsStreamSubscription;

  TokenCurrenciesRepository({
    required CurrentAccountsSource currentAccountsSource,
    required HiveSource hiveSource,
    required HttpSource httpSource,
  })  : _currentAccountsSource = currentAccountsSource,
        _hiveSource = hiveSource,
        _httpSource = httpSource {
    _currentAccountsStreamSubscription =
        Rx.combineLatest2<List<AssetsList>, void, List<AssetsList>>(
      _currentAccountsSource.currentAccountsStream,
      Stream<void>.periodic(kCurrenciesRefreshTimeout).startWith(null),
      (a, b) => a,
    ).listen((e) => _currentAccountsStreamListener(e));
  }

  Stream<List<Currency>> get currenciesStream => _hiveSource.currenciesStream;

  List<Currency> get currencies => _hiveSource.currencies;

  Future<void> clear() => _hiveSource.clearCurrencies();

  Future<void> dispose() => _currentAccountsStreamSubscription.cancel();

  Future<void> _currentAccountsStreamListener(List<AssetsList> event) async {
    try {
      final rootTokenContracts = [
        ...{
          kAddressForEverCurrency,
          ...event
              .map((e) => e.additionalAssets.values.map((e) => e.tokenWallets).expand((e) => e))
              .expand((e) => e)
              .map((e) => e.rootTokenContract),
        }
      ];

      for (final rootTokenContract in rootTokenContracts) {
        try {
          final currency = await _httpSource.getCurrency(rootTokenContract);

          await _hiveSource.saveCurrency(
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
