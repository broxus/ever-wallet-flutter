import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../models/account_interaction.dart';
import '../../models/bookmark.dart';
import '../../models/currency.dart';
import '../../models/permissions.dart';
import '../../models/site_meta_data.dart';
import '../../models/token_contract_asset.dart';
import '../../models/token_wallet_info.dart';
import '../../models/ton_wallet_info.dart';
import '../../models/wallet_contract_type.dart';

@preResolve
@lazySingleton
class HiveSource {
  static const _keysPasswordsBoxName = 'keys_passwords_v1';
  static const _userPreferencesBoxName = 'user_preferences_v1';
  static const _systemTokenContractAssetsBoxName = 'system_token_contract_assets_v1';
  static const _customTokenContractAssetsBoxName = 'custom_token_contract_assets_v1';
  static const _tonWalletInfosBoxName = 'ton_wallet_infos_v7';
  static const _tokenWalletInfosBoxName = 'token_wallet_infos_v7';
  static const _tonWalletTransactionsBoxName = 'ton_wallet_transactions_v9';
  static const _tokenWalletTransactionsBoxName = 'token_wallet_transactions_v9';
  static const _publicKeysLabelsBoxName = 'public_keys_labels_v1';
  static const _preferencesBoxName = 'nekoton_preferences';
  static const _permissionsBoxName = 'nekoton_permissions_v1';
  static const _externalAccountsBoxName = 'nekoton_external_accounts';
  static const _bookmarksBoxName = 'bookmarks_box_v2';
  static const _searchHistoryBoxName = 'search_history_v1';
  static const _siteMetaDataBoxName = 'site_meta_data_v1';
  static const _currenciesBoxName = 'currencies_v1';
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
  late final Box<Bookmark> _bookmarksBox;
  late final Box<String> _searchHistoryBox;
  late final Box<SiteMetaData> _sitesMetaDataBox;
  late final Box<Currency> _currenciesBox;

  @factoryMethod
  static Future<HiveSource> create() async {
    final instance = HiveSource();
    await instance._initialize();
    return instance;
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

  TonWalletInfo? getTonWalletInfo({
    required String address,
    required String group,
  }) =>
      _tonWalletInfosBox.get('${address}_$group');

  Future<void> saveTonWalletInfo({
    required String address,
    required String group,
    required TonWalletInfo info,
  }) =>
      _tonWalletInfosBox.put('${address}_$group', info);

  Future<void> removeTonWalletInfo(String address) {
    final keys = _tonWalletInfosBox.keys.cast<String>().where((e) => e.contains(address));

    return _tonWalletInfosBox.deleteAll(keys);
  }

  Future<void> clearTonWalletInfos() => _tonWalletInfosBox.clear();

  TokenWalletInfo? getTokenWalletInfo({
    required String owner,
    required String rootTokenContract,
    required String group,
  }) =>
      _tokenWalletInfosBox.get('${owner}_${rootTokenContract}_$group');

  Future<void> saveTokenWalletInfo({
    required String owner,
    required String rootTokenContract,
    required String group,
    required TokenWalletInfo info,
  }) =>
      _tokenWalletInfosBox.put('${owner}_${rootTokenContract}_$group', info);

  Future<void> removeTokenWalletInfo({
    required String owner,
    required String rootTokenContract,
  }) {
    final keys = _tokenWalletInfosBox.keys.cast<String>().where((e) => e.contains('${owner}_$rootTokenContract'));

    return _tokenWalletInfosBox.deleteAll(keys);
  }

  Future<void> clearTokenWalletInfos() => _tokenWalletInfosBox.clear();

  List<TonWalletTransactionWithData>? getTonWalletTransactions({
    required String address,
    required String group,
  }) =>
      _tonWalletTransactionsBox.get('${address}_$group')?.cast<TonWalletTransactionWithData>();

  Future<void> saveTonWalletTransactions({
    required String address,
    required String group,
    required List<TonWalletTransactionWithData> transactions,
  }) =>
      _tonWalletTransactionsBox.put('${address}_$group', transactions.take(200).toList());

  Future<void> removeTonWalletTransactions(String address) {
    final keys = _tonWalletTransactionsBox.keys.cast<String>().where((e) => e.contains(address));

    return _tonWalletTransactionsBox.deleteAll(keys);
  }

  Future<void> clearTonWalletTransactions() => _tonWalletTransactionsBox.clear();

  List<TokenWalletTransactionWithData>? getTokenWalletTransactions({
    required String owner,
    required String rootTokenContract,
    required String group,
  }) =>
      _tokenWalletTransactionsBox.get('${owner}_${rootTokenContract}_$group')?.cast<TokenWalletTransactionWithData>();

  Future<void> saveTokenWalletTransactions({
    required String owner,
    required String rootTokenContract,
    required String group,
    required List<TokenWalletTransactionWithData> transactions,
  }) =>
      _tokenWalletTransactionsBox.put('${owner}_${rootTokenContract}_$group', transactions.take(200).toList());

  Future<void> removeTokenWalletTransactions({
    required String owner,
    required String rootTokenContract,
  }) {
    final keys =
        _tokenWalletTransactionsBox.keys.cast<String>().where((e) => e.contains('${owner}_$rootTokenContract'));

    return _tokenWalletTransactionsBox.deleteAll(keys);
  }

  Future<void> clearTokenWalletTransactions() => _tokenWalletTransactionsBox.clear();

  bool get isBiometryEnabled => (_userPreferencesBox.get(_biometryStatusKey, defaultValue: false) as bool?)!;

  Future<void> setIsBiometryEnabled({
    required bool isEnabled,
  }) =>
      _userPreferencesBox.put(_biometryStatusKey, isEnabled);

  Future<void> clearUserPreferences() => _userPreferencesBox.clear();

  String? getKeyPassword(String publicKey) => _keysPasswordsBox.get(publicKey);

  Future<void> setKeyPassword({
    required String publicKey,
    required String password,
  }) =>
      _keysPasswordsBox.put(publicKey, password);

  Future<void> clearKeysPasswords() => _keysPasswordsBox.clear();

  Map<String, String> get publicKeysLabels => _publicKeysLabelsBox.toMap().cast<String, String>();

  Future<void> setPublicKeyLabel({
    required String publicKey,
    required String label,
  }) =>
      _publicKeysLabelsBox.put(publicKey, label);

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

  Future<void> deletePermissionsForOrigin(String origin) => _permissionsBox.delete(origin);

  Future<void> deletePermissionsForAccount(String address) async {
    final origins = permissions.entries.where((e) => e.value.accountInteraction?.address == address).map((e) => e.key);

    for (final origin in origins) {
      final permissions = _permissionsBox.get(origin)!.copyWith(accountInteraction: null);

      await _permissionsBox.put(origin, permissions);
    }
  }

  Map<String, List<String>> get externalAccounts =>
      _externalAccountsBox.toMap().map((k, v) => MapEntry(k as String, v.cast<String>()));

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

  List<Bookmark> get bookmarks => _bookmarksBox.values.toList();

  Future<void> putBookmark(Bookmark bookmark) => _bookmarksBox.put(bookmark.id, bookmark);

  Future<void> deleteBookmark(int id) => _bookmarksBox.delete(id);

  Future<void> clearBookmarks() => _bookmarksBox.clear();

  List<String> get searchHistory => _searchHistoryBox.values.toList();

  Future<void> addSearchHistoryEntry(String entry) async {
    var list = _searchHistoryBox.toMap().cast<int, String>().entries;

    var key = 0;

    if (list.isNotEmpty) key = list.map((e) => e.key).reduce(max) + 1;

    list = list.where((e) => e.value != entry);

    final entries = [
      ...list,
      MapEntry(key, entry),
    ]..sort((a, b) => -a.key.compareTo(b.key));

    await _searchHistoryBox.clear();

    await _searchHistoryBox.putAll(Map.fromEntries(entries.take(50)));
  }

  Future<void> removeSearchHistoryEntry(String entry) async {
    final keys = _searchHistoryBox.toMap().cast<int, String>().entries.where((e) => e.value == entry).map((e) => e.key);

    for (final key in keys) {
      await _searchHistoryBox.delete(key);
    }
  }

  Future<void> clearSearchHistory() => _searchHistoryBox.clear();

  SiteMetaData? getSiteMetaData(String url) => _sitesMetaDataBox.get(url);

  Future<void> cacheSiteMetaData({
    required String url,
    required SiteMetaData metaData,
  }) =>
      _sitesMetaDataBox.put(url, metaData);

  Future<void> clearSitesMetaData() => _sitesMetaDataBox.clear();

  List<Currency> get currencies => _currenciesBox.values.toList();

  Future<void> saveCurrency({
    required String address,
    required Currency currency,
  }) =>
      _currenciesBox.put(address, currency);

  Future<void> clearCurrencies() => _currenciesBox.clear();

  Future<void> _initialize() async {
    final hiveAesCipherKeyList = dotenv.env['HIVE_AES_CIPHER_KEY']?.split(' ').map((e) => int.parse(e)).toList();
    final hiveAesCipherKey = hiveAesCipherKeyList != null ? Uint8List.fromList(hiveAesCipherKeyList) : null;

    if (hiveAesCipherKey == null) throw Exception('Provide HIVE_AES_CIPHER_KEY in .env file in correct format!');

    _key = hiveAesCipherKey;

    await Hive.initFlutter();

    Hive
      ..registerAdapter(TokenContractAssetAdapter())
      ..registerAdapter(AccountStatusAdapter())
      ..registerAdapter(MessageAdapter())
      ..registerAdapter(TokenIncomingTransferAdapter())
      ..registerAdapter(TokenOutgoingTransferAdapter())
      ..registerAdapter(TokenSwapBackAdapter())
      ..registerAdapter(TokenWalletTransactionIncomingTransferAdapter())
      ..registerAdapter(TokenWalletTransactionOutgoingTransferAdapter())
      ..registerAdapter(TokenWalletTransactionSwapBackAdapter())
      ..registerAdapter(KnownPayloadCommentAdapter())
      ..registerAdapter(KnownPayloadTokenSwapBackAdapter())
      ..registerAdapter(TokenWalletTransactionAcceptAdapter())
      ..registerAdapter(TokenWalletTransactionTransferBouncedAdapter())
      ..registerAdapter(TokenWalletTransactionSwapBackBouncedAdapter())
      ..registerAdapter(TokenWalletTransactionWithDataAdapter())
      ..registerAdapter(TransactionAdapter())
      ..registerAdapter(TransactionIdAdapter())
      ..registerAdapter(TransferRecipientOwnerWalletAdapter())
      ..registerAdapter(TransferRecipientTokenWalletAdapter())
      ..registerAdapter(TransactionAdditionalInfoDePoolOnRoundCompleteAdapter())
      ..registerAdapter(TransactionAdditionalInfoDePoolReceiveAnswerAdapter())
      ..registerAdapter(MultisigConfirmTransactionAdapter())
      ..registerAdapter(MultisigSendTransactionAdapter())
      ..registerAdapter(MultisigSubmitTransactionAdapter())
      ..registerAdapter(MultisigTransactionSendAdapter())
      ..registerAdapter(MultisigTransactionSubmitAdapter())
      ..registerAdapter(MultisigTransactionConfirmAdapter())
      ..registerAdapter(KnownPayloadTokenOutgoingTransferAdapter())
      ..registerAdapter(TokenWalletDeployedNotificationAdapter())
      ..registerAdapter(TonWalletTransactionWithDataAdapter())
      ..registerAdapter(TransactionAdditionalInfoCommentAdapter())
      ..registerAdapter(DePoolOnRoundCompleteNotificationAdapter())
      ..registerAdapter(DePoolReceiveAnswerNotificationAdapter())
      ..registerAdapter(TransactionAdditionalInfoTokenWalletDeployedAdapter())
      ..registerAdapter(TransactionAdditionalInfoWalletInteractionAdapter())
      ..registerAdapter(WalletInteractionInfoAdapter())
      ..registerAdapter(WalletInteractionMethodWalletV3TransferAdapter())
      ..registerAdapter(WalletTypeMultisigAdapter())
      ..registerAdapter(WalletContractTypeAdapter())
      ..registerAdapter(PermissionsAdapter())
      ..registerAdapter(AccountInteractionAdapter())
      ..registerAdapter(TonWalletInfoAdapter())
      ..registerAdapter(TonWalletDetailsAdapter())
      ..registerAdapter(TokenWalletVersionAdapter())
      ..registerAdapter(SymbolAdapter())
      ..registerAdapter(LastTransactionIdAdapter())
      ..registerAdapter(GenTimingsAdapter())
      ..registerAdapter(ContractStateAdapter())
      ..registerAdapter(WalletTypeWalletV3Adapter())
      ..registerAdapter(WalletTypeHighloadWalletV2Adapter())
      ..registerAdapter(WalletInteractionMethodMultisigAdapter())
      ..registerAdapter(MultisigTypeAdapter())
      ..registerAdapter(TokenWalletInfoAdapter())
      ..registerAdapter(AssetsListAdapter())
      ..registerAdapter(TonWalletAssetAdapter())
      ..registerAdapter(AdditionalAssetsAdapter())
      ..registerAdapter(TokenWalletAssetAdapter())
      ..registerAdapter(DePoolAssetAdapter())
      ..registerAdapter(BookmarkAdapter())
      ..registerAdapter(SiteMetaDataAdapter())
      ..registerAdapter(CurrencyAdapter());

    _keysPasswordsBox = await Hive.openBox(_keysPasswordsBoxName, encryptionCipher: HiveAesCipher(_key));
    _userPreferencesBox = await Hive.openBox(_userPreferencesBoxName);
    _systemTokenContractAssetsBox = await Hive.openBox(_systemTokenContractAssetsBoxName);
    _customTokenContractAssetsBox = await Hive.openBox(_customTokenContractAssetsBoxName);
    _tonWalletInfosBox = await Hive.openBox(_tonWalletInfosBoxName);
    _tokenWalletInfosBox = await Hive.openBox(_tokenWalletInfosBoxName);
    _tonWalletTransactionsBox = await Hive.openBox(_tonWalletTransactionsBoxName);
    _tokenWalletTransactionsBox = await Hive.openBox(_tokenWalletTransactionsBoxName);
    _publicKeysLabelsBox = await Hive.openBox(_publicKeysLabelsBoxName);
    _preferencesBox = await Hive.openBox(_preferencesBoxName);
    _permissionsBox = await Hive.openBox(_permissionsBoxName);
    _externalAccountsBox = await Hive.openBox(_externalAccountsBoxName);
    _bookmarksBox = await Hive.openBox(_bookmarksBoxName);
    _searchHistoryBox = await Hive.openBox(_searchHistoryBoxName);
    _sitesMetaDataBox = await Hive.openBox(_siteMetaDataBoxName);
    _currenciesBox = await Hive.openBox(_currenciesBoxName);
  }
}
