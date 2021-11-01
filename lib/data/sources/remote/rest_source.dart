import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:crystal/data/dtos/ton_assets_manifest_dto.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class RestSource {
  final Dio _dio = Dio();

  String _getTonAssetsManifestRoute() => 'https://raw.githubusercontent.com/broxus/ton-assets/master/manifest.json';

  String _getGravatarRoute(String hash) => 'https://www.gravatar.com/avatar/$hash?s=80&d=identicon&r=G';

  Future<TonAssetsManifestDto> getTonAssetsManifest() async {
    final response = await _dio.get<String>(_getTonAssetsManifestRoute());
    final json = jsonDecode(response.data!) as Map<String, dynamic>;
    return TonAssetsManifestDto.fromJson(json);
  }

  Future<String> getTokenSvgIcon(String url) async {
    final response = await _dio.get<String>(
      url,
      options: Options(responseType: ResponseType.plain),
    );
    return response.data!;
  }

  Future<List<int>> getGravatarIcon(String data) async {
    final hash = md5.convert(utf8.encode(data)).toString();
    final response = await _dio.get<List>(
      _getGravatarRoute(hash),
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data!.cast<int>();
  }
}
