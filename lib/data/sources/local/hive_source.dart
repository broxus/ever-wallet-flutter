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
  static const _systemTokenContractAssetsBoxName = 'system_token_contract_assets_v1';
  static const _customTokenContractAssetsBoxName = 'custom_token_contract_assets_v1';
  static const _tonWalletInfosBoxName = 'ton_wallet_infos_v5';
  static const _tokenWalletInfosBoxName = 'token_wallet_infos_v5';
  static const _tonWalletTransactionsBoxName = 'ton_wallet_transactions_v8';
  static const _tokenWalletTransactionsBoxName = 'token_wallet_transactions_v8';
  static const _publicKeysLabelsBoxName = 'public_keys_labels_v1';
  static const _preferencesBoxName = 'nekoton_preferences';
  static const _permissionsBoxName = 'nekoton_permissions_v1';
  static const _externalAccountsBoxName = 'nekoton_external_accounts';
  static const _biometryStatusKey = 'biometry_status';
  static const _currentPublicKeyKey = 'current_public_key';
  static const _currentConnectionKey = 'current_connection';
  late final Uint8List _key;
  late final Box<String> _keysPasswordsBox;
  late final Box<Object?> _userPreferencesBox;
  late final Box<TokenContractAsset> _systemTokenContractAssetsBox;
  late final Box<TokenContractAsset> _customTokenContractAssetsBox;
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

  List<TokenContractAsset> get systemTokenContractAssets => _systemTokenContractAssetsBox.values.toList();

  Future<void> updateSystemTokenContractAssets(List<TokenContractAsset> assets) async {
    await _systemTokenContractAssetsBox.clear();
    await _systemTokenContractAssetsBox.addAll(assets);
  }

  List<TokenContractAsset> get customTokenContractAssets => _customTokenContractAssetsBox.values.toList();

  Future<void> addCustomTokenContractAsset(TokenContractAsset tokenContractAsset) =>
      _customTokenContractAssetsBox.put(tokenContractAsset.address, tokenContractAsset);

  Future<void> removeCustomTokenContractAsset(String address) => _customTokenContractAssetsBox.delete(address);

  Future<void> clearCustomTokenContractAssets() => _customTokenContractAssetsBox.clear();

  TonWalletInfo? getTonWalletInfo(String address) => _tonWalletInfosBox.get(address);

  Future<void> saveTonWalletInfo(TonWalletInfo info) => _tonWalletInfosBox.put(info.address, info);

  Future<void> removeTonWalletInfo(String address) => _tonWalletInfosBox.delete(address);

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

  List<TonWalletTransactionWithData>? getTonWalletTransactions(String address) =>
      _tonWalletTransactionsBox.get(address.hashCode)?.cast<TonWalletTransactionWithData>();

  Future<void> saveTonWalletTransactions({
    required String address,
    required List<TonWalletTransactionWithData> transactions,
  }) async {
    var list = _tonWalletTransactionsBox.get(address.hashCode)?.cast<TonWalletTransactionWithData>() ?? [];

    list = [
      ...list,
      ...transactions,
    ]..sort((a, b) => a.transaction.compareTo(b.transaction));

    list = list.take(250).toList();

    await _tonWalletTransactionsBox.put(address.hashCode, list);
  }

  Future<void> removeTonWalletTransactions(String address) => _tonWalletTransactionsBox.delete(address.hashCode);

  Future<void> clearTonWalletTransactions() => _tonWalletTransactionsBox.clear();

  List<TokenWalletTransactionWithData>? getTokenWalletTransactions({
    required String owner,
    required String rootTokenContract,
  }) =>
      _tokenWalletTransactionsBox
          .get(owner.hashCode ^ rootTokenContract.hashCode)
          ?.cast<TokenWalletTransactionWithData>();

  Future<void> saveTokenWalletTransactions({
    required String owner,
    required String rootTokenContract,
    required List<TokenWalletTransactionWithData> transactions,
  }) async {
    var list = _tokenWalletTransactionsBox
            .get(owner.hashCode ^ rootTokenContract.hashCode)
            ?.cast<TokenWalletTransactionWithData>() ??
        [];

    list = [
      ...list,
      ...transactions,
    ]..sort((a, b) => a.transaction.compareTo(b.transaction));

    list = list.take(250).toList();

    await _tokenWalletTransactionsBox.put(owner.hashCode ^ rootTokenContract.hashCode, list);
  }

  Future<void> removeTokenWalletTransactions({
    required String owner,
    required String rootTokenContract,
  }) =>
      _tokenWalletTransactionsBox.delete(owner.hashCode ^ rootTokenContract.hashCode);

  Future<void> clearTokenWalletTransactions() => _tokenWalletTransactionsBox.clear();

  bool get isBiometryEnabled => (_userPreferencesBox.get(_biometryStatusKey, defaultValue: false) as bool?)!;

  Future<void> setIsBiometryEnabled(bool value) => _userPreferencesBox.put(_biometryStatusKey, value);

  Future<void> clearUserPreferences() => _userPreferencesBox.clear();

  String? getKeyPassword(String publicKey) => _keysPasswordsBox.get(publicKey);

  Future<void> setKeyPassword({
    required String publicKey,
    required String password,
  }) =>
      _keysPasswordsBox.put(publicKey, password);

  Future<void> clearKeysPasswords() => _keysPasswordsBox.clear();

  Future<void> setPublicKeyLabel({
    required String publicKey,
    required String label,
  }) =>
      _publicKeysLabelsBox.put(publicKey, label);

  Map<String, String> get publicKeysLabels => _publicKeysLabelsBox.toMap().cast<String, String>();

  Future<void> removePublicKeyLabel(String publicKey) => _publicKeysLabelsBox.delete(publicKey);

  Future<void> clearPublicKeysLabels() => _publicKeysLabelsBox.clear();

  String? get currentPublicKey => _preferencesBox.get(_currentPublicKeyKey) as String?;

  Future<void> setCurrentPublicKey(String? currentPublicKey) => _preferencesBox.put(
        _currentPublicKeyKey,
        currentPublicKey,
      );

  String? get currentConnection => _preferencesBox.get(_currentConnectionKey) as String?;

  Future<void> setCurrentConnection(String? currentConnection) => _preferencesBox.put(
        _currentConnectionKey,
        currentConnection,
      );

  Map<String, Permissions> get permissions => _permissionsBox.toMap().cast<String, Permissions>();

  Future<void> setPermissions({
    required String origin,
    required Permissions permissions,
  }) =>
      _permissionsBox.put(origin, permissions);

  Future<void> deletePermissions(String origin) => _permissionsBox.delete(origin);

  Future<void> deletePermissionsForAccount(String address) async {
    final origins = permissions.entries.where((e) => e.value.accountInteraction?.address == address).map((e) => e.key);

    for (final origin in origins) {
      final permissions = _permissionsBox.get(origin)!.copyWith(accountInteraction: null);

      await _permissionsBox.put(origin, permissions);
    }
  }

  Map<String, List<String>> get externalAccounts =>
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

    if (hiveAesCipherKey == null) throw Exception('Provide HIVE_AES_CIPHER_KEY in .env file in correct format!');

    _key = hiveAesCipherKey;

    _keysPasswordsBox = await Hive.openBox<String>(
      _keysPasswordsBoxName,
      encryptionCipher: HiveAesCipher(_key),
    );
    _userPreferencesBox = await Hive.openBox<Object?>(_userPreferencesBoxName);
    _systemTokenContractAssetsBox = await Hive.openBox<TokenContractAsset>(_systemTokenContractAssetsBoxName);
    _customTokenContractAssetsBox = await Hive.openBox<TokenContractAsset>(_customTokenContractAssetsBoxName);
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
