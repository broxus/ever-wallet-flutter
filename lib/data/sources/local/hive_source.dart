import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../models/token_contract_asset.dart';
import '../../models/token_wallet_info.dart';
import '../../models/ton_wallet_info.dart';

@preResolve
@lazySingleton
class HiveSource {
  static const _keysPasswordsBoxName = 'keys_passwords_v1';
  static const _userPreferencesBoxName = 'user_preferences_v1';
  static const _tokenContractAssetsBoxName = 'token_contract_assets_v5';
  static const _tonWalletInfosBoxName = 'ton_wallet_infos_v5';
  static const _tokenWalletInfosBoxName = 'token_wallet_infos_v5';
  static const _tonWalletTransactionsBoxName = 'ton_wallet_transactions_v6';
  static const _tokenWalletTransactionsBoxName = 'token_wallet_transactions_v6';
  static const _publicKeysLabelsBoxName = 'public_keys_labels_v1';
  static const _preferencesBoxName = 'nekoton_preferences';
  static const _permissionsBoxName = 'nekoton_permissions';
  static const _externalAccountsBoxName = 'nekoton_external_accounts';
  static const _biometryStatusKey = 'biometry_status';
  static const _currentPublicKeyKey = 'current_public_key';
  static const _currentConnectionKey = 'current_connection';
  late final Uint8List _key;
  late final Box<String> _keysPasswordsBox;
  late final Box<Object?> _userPreferencesBox;
  late final Box<TokenContractAsset> _tokenContractAssetsBox;
  late final Box<TonWalletInfo> _tonWalletInfosBox;
  late final Box<TokenWalletInfo> _tokenWalletInfosBox;
  late final Box<List> _tonWalletTransactionsBox;
  late final Box<List> _tokenWalletTransactionsBox;
  late final Box<String> _publicKeysLabelsBox;
  late final Box<dynamic> _preferencesBox;
  late final Box<Permissions> _permissionsBox;
  late final Box<List> _externalAccountsBox;

  @factoryMethod
  static Future<HiveSource> create() async {
    final hiveSource = HiveSource();
    await hiveSource._initialize();
    return hiveSource;
  }

  List<TokenContractAsset> getTokenContractAssets() => _tokenContractAssetsBox.values.toList();

  Future<void> saveTokenContractAsset(TokenContractAsset asset) =>
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

  List<TonWalletTransactionWithData> getTonWalletTransactions(String address) => _tonWalletTransactionsBox
      .get(address.hashCode, defaultValue: [])!
      .whereNotNull()
      .toList()
      .cast<TonWalletTransactionWithData>();

  Future<void> saveTonWalletTransactions({
    required List<TonWalletTransactionWithData> tonWalletTransactions,
    required String address,
  }) =>
      _tonWalletTransactionsBox.put(address.hashCode, tonWalletTransactions);

  Future<void> removeTonWalletTransactions(String address) => _tonWalletTransactionsBox.delete(address);

  Future<void> clearTonWalletTransactions() => _tonWalletTransactionsBox.clear();

  List<TokenWalletTransactionWithData> getTokenWalletTransactions({
    required String owner,
    required String rootTokenContract,
  }) =>
      _tokenWalletTransactionsBox
          .get(owner.hashCode ^ rootTokenContract.hashCode, defaultValue: [])!
          .whereNotNull()
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

  String? getCurrentPublicKey() => _preferencesBox.get(_currentPublicKeyKey) as String?;

  Future<void> setCurrentPublicKey(String? currentPublicKey) => _preferencesBox.put(
        _currentPublicKeyKey,
        currentPublicKey,
      );

  String? getCurrentConnection() => _preferencesBox.get(_currentConnectionKey) as String?;

  Future<void> setCurrentConnection(String? currentConnection) => _preferencesBox.put(
        _currentConnectionKey,
        currentConnection,
      );

  Permissions getPermissions(String origin) => _permissionsBox.get(origin) ?? const Permissions();

  Future<void> setPermissions({
    required String origin,
    required Permissions permissions,
  }) =>
      _permissionsBox.put(origin, permissions);

  Future<void> deletePermissions(String origin) => _permissionsBox.delete(origin);

  Future<void> deletePermissionsForAccount(String address) async {
    final newValues = _permissionsBox.values.where((e) => e.accountInteraction?.address != address);

    await _permissionsBox.clear();
    await _permissionsBox.addAll(newValues);
  }

  Map<String, List<String>> getExternalAccounts() =>
      _externalAccountsBox.toMap().map((key, value) => MapEntry(key as String, value.cast<String>()));

  Future<void> addExternalAccount({
    required String publicKey,
    required String address,
  }) async {
    final list = _externalAccountsBox.get(publicKey)?.cast<String>().where((e) => e != address).toList() ?? [];

    list.add(address);

    await _externalAccountsBox.put(publicKey, list);
  }

  Future<void> removeExternalAccount({
    required String publicKey,
    required String address,
  }) async {
    final list = _externalAccountsBox.get(publicKey)?.cast<String>().where((e) => e != address).toList();

    if (list == null) return;

    if (list.isNotEmpty) {
      await _externalAccountsBox.put(publicKey, list);
    } else {
      await _externalAccountsBox.delete(publicKey);
    }
  }

  Future<void> clearExternalAccounts() => _externalAccountsBox.clear();

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
    _tokenContractAssetsBox = await Hive.openBox<TokenContractAsset>(_tokenContractAssetsBoxName);
    _tonWalletInfosBox = await Hive.openBox<TonWalletInfo>(_tonWalletInfosBoxName);
    _tokenWalletInfosBox = await Hive.openBox<TokenWalletInfo>(_tokenWalletInfosBoxName);
    _tonWalletTransactionsBox = await Hive.openBox<List>(_tonWalletTransactionsBoxName);
    _tokenWalletTransactionsBox = await Hive.openBox<List>(_tokenWalletTransactionsBoxName);
    _publicKeysLabelsBox = await Hive.openBox<String>(_publicKeysLabelsBoxName);
    _preferencesBox = await Hive.openBox(_preferencesBoxName);
    _permissionsBox = await Hive.openBox(_permissionsBoxName);
    _externalAccountsBox = await Hive.openBox(_externalAccountsBoxName);
  }
}
