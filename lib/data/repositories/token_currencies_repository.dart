import 'dart:async';

import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/models/currency.dart';
import 'package:ever_wallet/data/sources/local/current_accounts_source.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/data/sources/remote/http_source.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

class TokenCurrenciesRepository {
  final CurrentAccountsSource _currentAccountsSource;
  final HiveSource _hiveSource;
  final HttpSource _httpSource;
  final _tokenCurrenciesSubject = BehaviorSubject<List<Currency>>.seeded([]);
  late final StreamSubscription _currentAccountsStreamSubscription;

  TokenCurrenciesRepository(
    this._currentAccountsSource,
    this._hiveSource,
    this._httpSource,
  ) {
    _tokenCurrenciesSubject.add(_hiveSource.currencies);

    _currentAccountsStreamSubscription =
        Rx.combineLatest2<List<AssetsList>, void, List<AssetsList>>(
      _currentAccountsSource.currentAccountsStream,
      Stream<void>.periodic(kCurrenciesRefreshTimeout).startWith(null),
      (a, b) => a,
    ).listen((event) => _currentAccountsStreamListener(event));
  }

  Stream<List<Currency>> get currenciesStream =>
      _tokenCurrenciesSubject.distinct((a, b) => listEquals(a, b));

  List<Currency> get currencies => _tokenCurrenciesSubject.value;

  Future<void> clear() => _hiveSource.clearCurrencies();

  Future<void> dispose() async {
    await _currentAccountsStreamSubscription.cancel();

    await _tokenCurrenciesSubject.close();
  }

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

          _tokenCurrenciesSubject.add(_hiveSource.currencies);
        } catch (err) {
          // logger.e(err, err, st);
        }
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
