import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../dtos/token_contract_asset_dto.dart';

@preResolve
@lazySingleton
class HiveSource {
  static const _keysPasswordsBoxName = 'keys_passwords_v1';
  static const _userPreferencesBoxName = 'user_preferences_v1';
  static const _tokenContractAssetsBoxName = 'token_contract_assets_v1';
  static const _tonWalletInfosBoxName = 'ton_wallet_infos_v3';
  static const _tokenWalletInfosBoxName = 'token_wallet_infos_v3';
  static const _tonWalletTransactionsBoxName = 'ton_wallet_transactions_v2';
  static const _tokenWalletTransactionsBoxName = 'token_wallet_transactions_v2';
  static const _publicKeysLabelsBoxName = 'public_keys_labels_v1';
  static const _biometryStatusKey = 'biometry_status';
  late final Uint8List _key;
  late final Box<String> _keysPasswordsBox;
  late final Box<Object?> _userPreferencesBox;
  late final Box<TokenContractAssetDto> _tokenContractAssetsBox;
  late final Box<TonWalletInfo> _tonWalletInfosBox;
  late final Box<TokenWalletInfo> _tokenWalletInfosBox;
  late final Box<List> _tonWalletTransactionsBox;
  late final Box<List> _tokenWalletTransactionsBox;
  late final Box<String> _publicKeysLabelsBox;

  @factoryMethod
  static Future<HiveSource> create() async {
    final hiveSource = HiveSource();
    await hiveSource._initialize();
    return hiveSource;
  }

  List<TokenContractAssetDto> getTokenContractAssets() => _tokenContractAssetsBox.values.toList();

  Future<void> saveTokenContractAsset(TokenContractAssetDto asset) =>
      _tokenContractAssetsBox.put(asset.address.hashCode, asset);

  Future<void> removeTokenContractAsset(String address) => _tokenContractAssetsBox.delete(address.hashCode);

  Future<void> clearTokenContractAssets() => _tokenContractAssetsBox.clear();

  TonWalletInfo? getTonWalletInfo(String address) =>
      _tonWalletInfosBox.values.firstWhereOrNull((e) => e.address == address);

  Future<void> saveTonWalletInfo(TonWalletInfo tonWalletInfo) =>
      _tonWalletInfosBox.put(tonWalletInfo.address.hashCode, tonWalletInfo);

  Future<void> removeTonWalletInfo(String address) => _tonWalletInfosBox.delete(address.hashCode);

  Future<void> clearTonWalletInfos() => _tonWalletInfosBox.clear();

  TokenWalletInfo? getTokenWalletInfo({
    required String owner,
    required String rootTokenContract,
  }) =>
      _tokenWalletInfosBox.values
          .firstWhereOrNull((e) => e.owner == owner && e.symbol.rootTokenContract == rootTokenContract);

  Future<void> saveTokenWalletInfo(TokenWalletInfo tokenWalletInfo) => _tokenWalletInfosBox.put(
        tokenWalletInfo.owner.hashCode ^ tokenWalletInfo.symbol.rootTokenContract.hashCode,
        tokenWalletInfo,
      );

  Future<void> removeTokenWalletInfo({
    required String owner,
    required String rootTokenContract,
  }) =>
      _tokenWalletInfosBox.delete(owner.hashCode ^ rootTokenContract.hashCode);

  Future<void> clearTokenWalletInfos() => _tokenWalletInfosBox.clear();

  List<TonWalletTransactionWithData>? getTonWalletTransactions(String address) => _tonWalletTransactionsBox
      .get(address.hashCode)
      ?.where((e) => e != null)
      .toList()
      .cast<TonWalletTransactionWithData>();

  Future<void> saveTonWalletTransactions({
    required List<TonWalletTransactionWithData> tonWalletTransactions,
    required String address,
  }) =>
      _tonWalletTransactionsBox.put(address.hashCode, tonWalletTransactions);

  Future<void> removeTonWalletTransactions(String address) => _tonWalletTransactionsBox.delete(address);

  Future<void> clearTonWalletTransactions() => _tonWalletTransactionsBox.clear();

  List<TokenWalletTransactionWithData>? getTokenWalletTransactions({
    required String owner,
    required String rootTokenContract,
  }) =>
      _tokenWalletTransactionsBox
          .get(owner.hashCode ^ rootTokenContract.hashCode)
          ?.where((e) => e != null)
          .toList()
          .cast<TokenWalletTransactionWithData>();

  Future<void> saveTokenWalletTransactions({
    required List<TokenWalletTransactionWithData> tokenWalletTransactions,
    required String owner,
    required String rootTokenContract,
  }) =>
      _tokenWalletTransactionsBox.put(owner.hashCode ^ rootTokenContract.hashCode, tokenWalletTransactions);

  Future<void> removeTokenWalletTransactions({
    required String owner,
    required String rootTokenContract,
  }) =>
      _tokenWalletTransactionsBox.delete(owner.hashCode ^ rootTokenContract.hashCode);

  Future<void> clearTokenWalletTransactions() => _tokenWalletTransactionsBox.clear();

  Future<void> setBiometryStatus(bool isEnabled) => _userPreferencesBox.put(_biometryStatusKey, isEnabled);

  bool getBiometryStatus() => _userPreferencesBox.get(_biometryStatusKey) as bool? ?? false;

  Future<void> clearUserPreferences() => _userPreferencesBox.clear();

  Future<void> setKeyPassword({
    required String publicKey,
    required String password,
  }) =>
      _keysPasswordsBox.put(publicKey, password);

  String? getKeyPassword(String publicKey) => _keysPasswordsBox.get(publicKey);

  Future<void> clearKeysPasswords() => _keysPasswordsBox.clear();

  Future<void> setPublicKeyLabel({
    required String publicKey,
    required String label,
  }) =>
      _publicKeysLabelsBox.put(publicKey, label);

  Map<String, String> getPublicKeysLabels() => _publicKeysLabelsBox.toMap().cast<String, String>();

  Future<void> removePublicKeyLabel(String publicKey) => _publicKeysLabelsBox.delete(publicKey);

  Future<void> clearPublicKeysLabels() => _publicKeysLabelsBox.clear();

  Future<void> _initialize() async {
    final hiveAesCipherKeyString = dotenv.env['HIVE_AES_CIPHER_KEY'];
    final hiveAesCipherKeyList = hiveAesCipherKeyString?.split(' ').map((e) => int.parse(e)).toList();
    final hiveAesCipherKey = hiveAesCipherKeyList != null ? Uint8List.fromList(hiveAesCipherKeyList) : null;

    if (hiveAesCipherKey == null) {
      throw Exception('Provide HIVE_AES_CIPHER_KEY in .env file in correct format!');
    }

    _key = hiveAesCipherKey;

    _keysPasswordsBox = await Hive.openBox<String>(
      _keysPasswordsBoxName,
      encryptionCipher: HiveAesCipher(_key),
    );
    _userPreferencesBox = await Hive.openBox<Object?>(_userPreferencesBoxName);
    _tokenContractAssetsBox = await Hive.openBox<TokenContractAssetDto>(_tokenContractAssetsBoxName);
    _tonWalletInfosBox = await Hive.openBox<TonWalletInfo>(_tonWalletInfosBoxName);
    _tokenWalletInfosBox = await Hive.openBox<TokenWalletInfo>(_tokenWalletInfosBoxName);
    _tonWalletTransactionsBox = await Hive.openBox<List>(_tonWalletTransactionsBoxName);
    _tokenWalletTransactionsBox = await Hive.openBox<List>(_tokenWalletTransactionsBoxName);
    _publicKeysLabelsBox = await Hive.openBox<String>(_publicKeysLabelsBoxName);
  }
}
