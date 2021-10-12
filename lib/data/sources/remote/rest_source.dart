import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../dtos/token_contract_asset_dto.dart';

@lazySingleton
class RestSource {
  final Dio _dio = Dio();

  String _getTonAssetsRoute() => 'https://raw.githubusercontent.com/broxus/ton-assets/master/manifest.json';

  Future<List<TokenContractAssetDto>> getTokenContractAssets() async {
    final response = await _dio.get(_getTonAssetsRoute());

    final data = jsonDecode(response.data as String);
    final json = data as Map<String, dynamic>;
    final tokensData = json["tokens"] as List<dynamic>;
    final tokens = tokensData.cast<Map<String, dynamic>>();

    return tokens.map((e) => TokenContractAssetDto.fromJson(e)).toList();
  }
}
