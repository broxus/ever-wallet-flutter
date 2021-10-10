import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../dtos/connected_site_dto.dart';
import '../../dtos/token_contract_asset_dto.dart';

@preResolve
@lazySingleton
class HiveSource {
  late final Uint8List _key;
  final _biometryStatus = "biometry_status";
  final _currentPublicKey = "current_public_key";

  @factoryMethod
  static Future<HiveSource> create() async {
    final hiveSource = HiveSource();

    final hiveAesCipherKeyString = dotenv.env['HIVE_AES_CIPHER_KEY'];
    final hiveAesCipherKeyList = hiveAesCipherKeyString?.split(" ").map((e) => int.parse(e)).toList();
    final hiveAesCipherKey = hiveAesCipherKeyList != null ? Uint8List.fromList(hiveAesCipherKeyList) : null;

    if (hiveAesCipherKey == null) {
      throw Exception('Provide HIVE_AES_CIPHER_KEY in .env file in correct format!');
    }

    hiveSource._key = hiveAesCipherKey;

    return hiveSource;
  }

  Future<Box<TokenContractAssetDto>> get _tokenContractAssetsBox async =>
      Hive.openBox<TokenContractAssetDto>("token_contract_assets");

  Future<Box<String>> get _bookmarksBox async => Hive.openBox<String>("bookmarks");

  Future<Box<List>> get _connectedSitesBox async => Hive.openBox<List>("connected_sites");

  Future<Box<Object?>> get _biometryPreferencesBox async => Hive.openBox<Object?>("biometry_preferences");

  Future<Box<Object?>> get _userPreferencesBox async => Hive.openBox<Object?>("user_preferences");

  Future<Box<String>> get _walletsPasswordsBox async => Hive.openBox<String>(
        "wallets_passwords",
        encryptionCipher: HiveAesCipher(_key),
      );

  Future<List<ConnectedSiteDto>> getConnectedSites(String address) async {
    final box = await _connectedSitesBox;
    return box.get(
      address,
      defaultValue: [],
    )!.cast<ConnectedSiteDto>();
  }

  Future<void> addConnectedSite({
    required String address,
    required ConnectedSiteDto site,
  }) async {
    final box = await _connectedSitesBox;

    final list = await getConnectedSites(address);
    list.add(site);

    await box.put(address, list);
  }

  Future<void> removeConnectedSite({
    required String address,
    required String url,
  }) async {
    final box = await _connectedSitesBox;

    final list = await getConnectedSites(address);
    final filtered = list.where((element) => element.url != url).toList();

    await box.clear();
    await box.put(address, filtered);
  }

  Future<void> clearConnectedSites() async {
    final box = await _connectedSitesBox;
    await box.clear();
  }

  Future<List<TokenContractAssetDto>> getTokenContractAssets() async {
    final box = await _tokenContractAssetsBox;
    return box.values.toList();
  }

  Future<void> cacheTokenContractAssets(List<TokenContractAssetDto> assets) async {
    final box = await _tokenContractAssetsBox;
    await box.clear();
    await box.addAll(assets);
  }

  Future<void> clearTokenContractAssets() async {
    final box = await _tokenContractAssetsBox;
    await box.clear();
  }

  Future<bool> get biometryStatus async {
    final box = await _biometryPreferencesBox;
    return box.get(_biometryStatus) as bool? ?? false;
  }

  Future<void> setBiometryStatus({required bool isEnabled}) async {
    final box = await _biometryPreferencesBox;
    return box.put(_biometryStatus, isEnabled);
  }

  Future<void> clearBiometryPreferences() async {
    final box = await _biometryPreferencesBox;
    await box.clear();
  }

  Future<String?> get currentPublicKey async {
    final box = await _userPreferencesBox;
    return box.get(_currentPublicKey) as String?;
  }

  Future<void> setCurrentPublicKey(String? currentPublicKey) async {
    final box = await _userPreferencesBox;
    await box.put(_currentPublicKey, currentPublicKey);
  }

  Future<void> clearUserPreferences() async {
    final box = await _userPreferencesBox;
    await box.clear();
  }

  Future<void> setKeyPassword({
    required String publicKey,
    required String password,
  }) async {
    final box = await _walletsPasswordsBox;
    await box.put(publicKey, password);
  }

  Future<String?> getKeyPassword(String publicKey) async {
    final box = await _walletsPasswordsBox;
    return box.get(publicKey);
  }

  Future<void> clearPasswords() async {
    final box = await _walletsPasswordsBox;
    await box.clear();
  }

  Future<List<String>> getBookmarks() async {
    final box = await _bookmarksBox;
    return box.values.toList();
  }

  Future<void> addBookmark(String url) async {
    final box = await _bookmarksBox;
    await box.put(url.hashCode, url);
  }

  Future<void> removeBookmark(String url) async {
    final box = await _bookmarksBox;
    await box.delete(url.hashCode);
  }
}
