import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../dtos/ton_assets_manifest_dto.dart';

@lazySingleton
class RestSource {
  final Dio _dio = Dio();

  String _getTonAssetsManifestRoute() => 'https://raw.githubusercontent.com/broxus/ton-assets/master/manifest.json';

  Future<TonAssetsManifestDto> getTonAssetsManifest() async {
    final response = await _dio.get<String>(_getTonAssetsManifestRoute());
    final json = jsonDecode(response.data!) as Map<String, dynamic>;
    return TonAssetsManifestDto.fromJson(json);
  }
}
