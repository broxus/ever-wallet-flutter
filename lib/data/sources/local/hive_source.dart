import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../dtos/token_contract_asset_dto.dart';

@preResolve
@lazySingleton
class HiveSource {
  late final Uint8List _key;
  final _biometryStatus = "biometry_status";
  late final Box<TokenContractAssetDto> _tokenContractAssetsBox;
  late final Box<Object?> _biometryPreferencesBox;
  late final Box<String> _walletsPasswordsBox;

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

    hiveSource._tokenContractAssetsBox = await Hive.openBox<TokenContractAssetDto>("token_contract_assets");
    hiveSource._biometryPreferencesBox = await Hive.openBox<Object?>("biometry_preferences");
    hiveSource._walletsPasswordsBox = await Hive.openBox<String>(
      "wallets_passwords_v2",
      encryptionCipher: HiveAesCipher(hiveSource._key),
    );

    return hiveSource;
  }

  Future<List<TokenContractAssetDto>> getTokenContractAssets() async {
    return _tokenContractAssetsBox.values.toList();
  }

  Future<void> cacheTokenContractAssets(List<TokenContractAssetDto> assets) async {
    await _tokenContractAssetsBox.clear();
    await _tokenContractAssetsBox.addAll(assets);
  }

  Future<void> clearTokenContractAssets() async {
    await _tokenContractAssetsBox.clear();
  }

  Future<void> setBiometryStatus({required bool isEnabled}) async {
    return _biometryPreferencesBox.put(_biometryStatus, isEnabled);
  }

  Future<bool> getBiometryStatus() async {
    return _biometryPreferencesBox.get(_biometryStatus) as bool? ?? false;
  }

  Future<void> clearBiometryPreferences() async {
    await _biometryPreferencesBox.clear();
  }

  Future<void> setKeyPassword({
    required String publicKey,
    required String password,
  }) async {
    await _walletsPasswordsBox.put(publicKey, password);
  }

  Future<String?> getKeyPassword(String publicKey) async {
    return _walletsPasswordsBox.get(publicKey);
  }

  Future<void> clearPasswords() async {
    await _walletsPasswordsBox.clear();
  }
}
