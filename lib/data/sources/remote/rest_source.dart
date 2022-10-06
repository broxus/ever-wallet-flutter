import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../models/currency.dart';
import '../../models/ton_assets_manifest.dart';

@lazySingleton
class RestSource {
  final Dio _dio = Dio();

  String _everTonAssetsManifestRoute() =>
      'https://raw.githubusercontent.com/broxus/ton-assets/master/manifest.json';

  String _venomTonAssetsManifestRoute() =>
      'https://raw.githubusercontent.com/BVFDT/venom-assets/master/manifest.json';

  String _everCurrenciesRoute(String address) => 'https://api.flatqube.io/v1/currencies/$address';

  String _venomCurrenciesRoute(String address) => 'https://api.web3.world/v1/currencies/$address';

  Future<TonAssetsManifest> getEverTonAssetsManifest() async {
    final response = await _dio.get<String>(_everTonAssetsManifestRoute());
    final json = jsonDecode(response.data!) as Map<String, dynamic>;
    final manifest = TonAssetsManifest.fromJson(json);

    return manifest;
  }

  Future<TonAssetsManifest> getVenomTonAssetsManifest() async {
    final response = await _dio.get<String>(_venomTonAssetsManifestRoute());
    final json = jsonDecode(response.data!) as Map<String, dynamic>;
    final manifest = TonAssetsManifest.fromJson(json);

    return manifest;
  }

  Future<Currency> getEverCurrency(String address) async {
    final response = await _dio.post<String>(_everCurrenciesRoute(address));
    final json = jsonDecode(response.data!) as Map<String, dynamic>;
    final currency = Currency.fromJson(json);

    return currency;
  }

  Future<Currency> getVenomCurrency(String address) async {
    final response = await _dio.post<String>(_venomCurrenciesRoute(address));
    final json = jsonDecode(response.data!) as Map<String, dynamic>;
    final currency = Currency.fromJson(json);

    return currency;
  }
}
