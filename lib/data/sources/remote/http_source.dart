import 'dart:convert';

import 'package:ever_wallet/data/models/currency.dart';
import 'package:ever_wallet/data/models/ton_assets_manifest.dart';
import 'package:http/http.dart' as http;

class HttpSource {
  Uri _everTonAssetsManifestRoute() =>
      Uri.parse('https://raw.githubusercontent.com/broxus/ton-assets/master/manifest.json');

  Uri _venomTonAssetsManifestRoute() =>
      Uri.parse('https://cdn.venom.foundation/assets/mainnet/manifest.json');

  Uri _everCurrenciesRoute(String address) =>
      Uri.parse('https://api.flatqube.io/v1/currencies/$address');

  Uri _venomCurrenciesRoute(String address) =>
      Uri.parse('https://api.web3.world/v1/currencies/$address');

  Future<String> postTransportData({
    required String endpoint,
    required Map<String, String> headers,
    required String data,
  }) async {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: headers,
      body: data,
    );

    return response.body;
  }

  Future<String> getTransportData(String endpoint) async {
    final response = await http.get(Uri.parse(endpoint));

    return response.body;
  }

  Future<TonAssetsManifest> getEverTonAssetsManifest() async {
    final response = await http.get(_everTonAssetsManifestRoute());
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final manifest = TonAssetsManifest.fromJson(json);

    return manifest;
  }

  Future<TonAssetsManifest> getVenomTonAssetsManifest() async {
    final response = await http.get(_venomTonAssetsManifestRoute());
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final manifest = TonAssetsManifest.fromJson(json);

    return manifest;
  }

  Future<Currency> getEverCurrency(String address) async {
    final response = await http.post(_everCurrenciesRoute(address));
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final currency = Currency.fromJson(json);

    return currency;
  }

  Future<Currency> getVenomCurrency(String address) async {
    final response = await http.post(_venomCurrenciesRoute(address));
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final currency = Currency.fromJson(json);

    return currency;
  }
}
