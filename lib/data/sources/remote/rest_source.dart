import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../models/ton_assets_manifest.dart';

@lazySingleton
class RestSource {
  final Dio _dio = Dio();

  String _tonAssetsManifestRoute() => 'https://raw.githubusercontent.com/broxus/ton-assets/master/manifest.json';

  Future<TonAssetsManifest> getTonAssetsManifest() async {
    final response = await _dio.get<String>(_tonAssetsManifestRoute());
    final json = jsonDecode(response.data!) as Map<String, dynamic>;
    return TonAssetsManifest.fromJson(json);
  }
}
