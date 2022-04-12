import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../logger.dart';
import '../constants.dart';
import '../models/currency.dart';
import '../sources/local/accounts_storage_source.dart';
import '../sources/local/hive_source.dart';
import '../sources/remote/rest_source.dart';

@lazySingleton
class TokenCurrenciesRepository {
  final AccountsStorageSource _accountsStorageSource;
  final HiveSource _hiveSource;
  final RestSource _restSource;
  final _tokenCurrenciesSubject = BehaviorSubject<List<Currency>>.seeded([]);

  TokenCurrenciesRepository(
    this._accountsStorageSource,
    this._hiveSource,
    this._restSource,
  ) {
    _tokenCurrenciesSubject.add(_hiveSource.currencies);

    Rx.combineLatest2<List<AssetsList>, void, List<AssetsList>>(
      _accountsStorageSource.currentAccountsStream,
      Stream<void>.periodic(kCurrenciesRefreshTimeout).startWith(null),
      (a, b) => a,
    ).listen((event) => _currentAccountsStreamListener(event));
  }

  Stream<List<Currency>> get currenciesStream => _tokenCurrenciesSubject.distinct((a, b) => listEquals(a, b));

  List<Currency> get currencies => _tokenCurrenciesSubject.value;

  Future<void> clear() => _hiveSource.clearCurrencies();

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
          final currency = await _restSource.getCurrency(rootTokenContract);

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
