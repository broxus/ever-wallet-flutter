import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../logger.dart';
import '../constants.dart';
import '../models/currency.dart';
import '../sources/local/accounts_storage_source.dart';
import '../sources/local/hive_source.dart';
import '../sources/remote/rest_source.dart';
import '../sources/remote/transport_source.dart';

@lazySingleton
class TokenCurrenciesRepository {
  final AccountsStorageSource _accountsStorageSource;
  final HiveSource _hiveSource;
  final RestSource _restSource;
  final TransportSource _transportSource;
  final _tokenCurrenciesSubject = BehaviorSubject<Map<String, List<Currency>>>.seeded({});

  TokenCurrenciesRepository(
    this._accountsStorageSource,
    this._hiveSource,
    this._restSource,
    this._transportSource,
  ) {
    _tokenCurrenciesSubject.add({
      'ever': _hiveSource.everCurrencies,
      'venom': _hiveSource.venomCurrencies,
    });

    Rx.combineLatest3<List<AssetsList>, Transport, void, Tuple2<List<AssetsList>, Transport>>(
      _accountsStorageSource.currentAccountsStream,
      _transportSource.transportStream,
      Stream<void>.periodic(kCurrenciesRefreshTimeout).startWith(null),
      (a, b, c) => Tuple2(a, b),
    ).listen((event) => _currentAccountsStreamListener(event));
  }

  Stream<Map<String, List<Currency>>> get currenciesStream => _tokenCurrenciesSubject;

  Future<void> clear() => _hiveSource.clearCurrencies();

  Future<void> _currentAccountsStreamListener(Tuple2<List<AssetsList>, Transport> event) async {
    try {
      final currentAccounts = event.item1;
      final transport = event.item2;

      final isEver = !transport.connectionData.name.contains('Venom');

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
              ? await _restSource.getEverCurrency(rootTokenContract)
              : await _restSource.getVenomCurrency(rootTokenContract);

          isEver
              ? await _hiveSource.saveEverCurrency(
                  address: rootTokenContract,
                  currency: currency,
                )
              : await _hiveSource.saveVenomCurrency(
                  address: rootTokenContract,
                  currency: currency,
                );

          _tokenCurrenciesSubject.add({
            'ever': _hiveSource.everCurrencies,
            'venom': _hiveSource.venomCurrencies,
          });
        } catch (err) {
          // logger.e(err, err, st);
        }
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
