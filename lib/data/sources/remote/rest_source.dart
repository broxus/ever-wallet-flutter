import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../models/currency.dart';
import '../../models/ton_assets_manifest.dart';

@lazySingleton
class RestSource {
  final Dio _dio = Dio();

  String _tonAssetsManifestRoute() => 'https://raw.githubusercontent.com/broxus/ton-assets/master/manifest.json';

  String _currenciesRoute(String address) => 'https://api.flatqube.io/v1/currencies/$address';

  Future<TonAssetsManifest> getTonAssetsManifest() async {
    final response = await _dio.get<String>(_tonAssetsManifestRoute());
    final json = jsonDecode(response.data!) as Map<String, dynamic>;
    final manifest = TonAssetsManifest.fromJson(json);

    return manifest;
  }

  Future<Currency> getCurrency(String address) async {
    final response = await _dio.post<String>(_currenciesRoute(address));
    final json = jsonDecode(response.data!) as Map<String, dynamic>;
    final currency = Currency.fromJson(json);

    return currency;
  }
}
