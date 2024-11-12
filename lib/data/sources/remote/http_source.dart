import 'dart:convert';

import 'package:ever_wallet/data/models/currency.dart';
import 'package:ever_wallet/data/models/ton_assets_manifest.dart';
import 'package:http/http.dart' as http;

class HttpSource {
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

  Future<TonAssetsManifest> getTonAssetsManifest(String url) async {
    final response = await http.get(Uri.parse(url));
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final manifest = TonAssetsManifest.fromJson(json);

    return manifest;
  }

  Future<Currency> getCurrency(String apiBaseUrl, String address) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/$address'),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final currency = Currency.fromJson(json);

    return currency;
  }
}
