import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ever_wallet/data/models/bookmark.dart';
import 'package:ever_wallet/data/models/browser_tabs_dto.dart';
import 'package:ever_wallet/data/models/currency.dart';
import 'package:ever_wallet/data/models/permissions.dart';
import 'package:ever_wallet/data/models/search_history_dto.dart';
import 'package:ever_wallet/data/models/site_meta_data.dart';
import 'package:ever_wallet/data/models/token_contract_asset.dart';
import 'package:ever_wallet/data/models/token_wallet_info.dart';
import 'package:ever_wallet/data/models/ton_wallet_info.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/account_interaction_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/account_status_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/bookmark_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/contract_state_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/currency_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/de_pool_on_round_complete_notification_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/de_pool_receive_answer_notification_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/gen_timings_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/last_transaction_id_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/message_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/multisig_confirm_transaction_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/multisig_send_transaction_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/multisig_submit_transaction_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/multisig_type_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/permissions_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/site_meta_data_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/symbol_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/token_contract_asset_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/token_incoming_transfer_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/token_outgoing_transfer_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/token_swap_back_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/token_wallet_deployed_notification_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/token_wallet_info_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/token_wallet_transaction_with_data_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/ton_wallet_details_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/ton_wallet_info_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/ton_wallet_transaction_with_data_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/transaction_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/transaction_id_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/wallet_contract_type_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/wallet_interaction_info_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/wallet_type_dto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HiveSource {
  final _keysPasswordsBoxName = 'keys_passwords_v1';
  final _userPreferencesBoxName = 'user_preferences_v1';
  final _systemTokenContractAssetsBoxName = 'system_token_contract_assets_v1';
  final _customTokenContractAssetsBoxName = 'custom_token_contract_assets_v1';
  final _tonWalletInfosBoxName = 'ton_wallet_infos_v8';
  final _tokenWalletInfosBoxName = 'token_wallet_infos_v8';
  final _tonWalletTransactionsBoxName = 'ton_wallet_transactions_v10';
  final _tokenWalletTransactionsBoxName = 'token_wallet_transactions_v10';
  final _publicKeysLabelsBoxName = 'public_keys_labels_v1';
  final _nekotonFlutterBoxName = 'nekoton_flutter';
  final _preferencesBoxName = 'nekoton_preferences';
  final _permissionsBoxName = 'nekoton_permissions_v1';
  final _externalAccountsBoxName = 'nekoton_external_accounts';
  final _bookmarksBoxName = 'bookmarks_box_v2';
  final _searchHistoryBoxName = 'search_history_v1';
  final _siteMetaDataBoxName = 'site_meta_data_v1';
  final _currenciesBoxName = 'currencies_v1';
  final _biometryStatusKey = 'biometry_status';
  final _currentPublicKeyKey = 'current_public_key';
  final _currentConnectionKey = 'current_connection';
  final _localeKey = 'locale';
  final _browserNeedKey = 'browser_need_key';
  final _browserTabsKey = 'browser_tabs_key';

  late final Uint8List _key;
  late final Box<String> _keysPasswordsBox;
  late final Box<Object?> _userPreferencesBox;
  late final Box<TokenContractAssetDto> _systemTokenContractAssetsBox;
  late final Box<TokenContractAssetDto> _customTokenContractAssetsBox;
  late final Box<TonWalletInfoDto> _tonWalletInfosBox;
  late final Box<TokenWalletInfoDto> _tokenWalletInfosBox;
  late final Box<List> _tonWalletTransactionsBox;
  late final Box<List> _tokenWalletTransactionsBox;
  late final Box<String> _publicKeysLabelsBox;
  late final Box<String> _nekotonFlutterBox;
  late final Box<dynamic> _preferencesBox;
  late final Box<PermissionsDto> _permissionsBox;
  late final Box<List> _externalAccountsBox;
  late final Box<BookmarkDto> _bookmarksBox;
  late final Box<SearchHistoryDto> _searchHistoryBox;
  late final Box<SiteMetaDataDto> _sitesMetaDataBox;
  late final Box<CurrencyDto> _currenciesBox;
  late final Box<bool> _browserNeedBox;
  late final Box<BrowserTabsDto> _browserTabsBox;

  HiveSource._();

  static Future<HiveSource> create() async {
    final instance = HiveSource._();
    await instance._initialize();
    return instance;
  }

  Future<String?> getStorageData(String key) async => _nekotonFlutterBox.get(key);

  Future<void> setStorageData({
    required String key,
    required String value,
  }) =>
      _nekotonFlutterBox.put(key, value);

  Future<void> removeStorageData(String key) => _nekotonFlutterBox.delete(key);

  List<TokenContractAsset> get systemTokenContractAssets =>
      _systemTokenContractAssetsBox.values.map((e) => e.toModel()).toList();

  Future<void> updateSystemTokenContractAssets(List<TokenContractAsset> assets) async {
    await _systemTokenContractAssetsBox.clear();
    await _systemTokenContractAssetsBox.addAll(assets.map((e) => e.toDto()));
  }

  List<TokenContractAsset> get customTokenContractAssets =>
      _customTokenContractAssetsBox.values.map((e) => e.toModel()).toList();

  Future<void> addCustomTokenContractAsset(TokenContractAsset tokenContractAsset) =>
      _customTokenContractAssetsBox.put(tokenContractAsset.address, tokenContractAsset.toDto());

  Future<void> removeCustomTokenContractAsset(String address) =>
      _customTokenContractAssetsBox.delete(address);

  Future<void> clearCustomTokenContractAssets() => _customTokenContractAssetsBox.clear();

  TonWalletInfo? getTonWalletInfo({
    required String address,
    required String group,
  }) =>
      _tonWalletInfosBox.get('${address}_$group')?.toDto();

  Future<void> saveTonWalletInfo({
    required String address,
    required String group,
    required TonWalletInfo info,
  }) =>
      _tonWalletInfosBox.put('${address}_$group', info.toDto());

  Future<void> removeTonWalletInfo(String address) {
    final keys = _tonWalletInfosBox.keys.cast<String>().where((e) => e.contains(address));

    return _tonWalletInfosBox.deleteAll(keys);
  }

  Future<void> clearTonWalletInfos() => _tonWalletInfosBox.clear();

  TokenWalletInfoDto? getTokenWalletInfo({
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
      _tokenWalletInfosBox.put('${owner}_${rootTokenContract}_$group', info.toDto());

  Future<void> removeTokenWalletInfo({
    required String owner,
    required String rootTokenContract,
  }) {
    final keys = _tokenWalletInfosBox.keys
        .cast<String>()
        .where((e) => e.contains('${owner}_$rootTokenContract'));

    return _tokenWalletInfosBox.deleteAll(keys);
  }

  Future<void> clearTokenWalletInfos() => _tokenWalletInfosBox.clear();

  List<TonWalletTransactionWithData>? getTonWalletTransactions({
    required String address,
    required String group,
  }) =>
      _tonWalletTransactionsBox
          .get('${address}_$group')
          ?.cast<TonWalletTransactionWithDataDto>()
          .map((e) => e.toModel())
          .toList();

  Future<void> saveTonWalletTransactions({
    required String address,
    required String group,
    required List<TonWalletTransactionWithData> transactions,
  }) =>
      _tonWalletTransactionsBox.put(
        '${address}_$group',
        transactions.take(200).map((e) => e.toDto()).toList(),
      );

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
      _tokenWalletTransactionsBox
          .get('${owner}_${rootTokenContract}_$group')
          ?.cast<TokenWalletTransactionWithDataDto>()
          .map((e) => e.toModel())
          .toList();

  Future<void> saveTokenWalletTransactions({
    required String owner,
    required String rootTokenContract,
    required String group,
    required List<TokenWalletTransactionWithData> transactions,
  }) =>
      _tokenWalletTransactionsBox.put(
        '${owner}_${rootTokenContract}_$group',
        transactions.take(200).map((e) => e.toDto()).toList(),
      );

  Future<void> removeTokenWalletTransactions({
    required String owner,
    required String rootTokenContract,
  }) {
    final keys = _tokenWalletTransactionsBox.keys
        .cast<String>()
        .where((e) => e.contains('${owner}_$rootTokenContract'));

    return _tokenWalletTransactionsBox.deleteAll(keys);
  }

  Future<void> clearTokenWalletTransactions() => _tokenWalletTransactionsBox.clear();

  String? get locale => _userPreferencesBox.get(_localeKey) as String?;

  Future<void> setLocale(String locale) => _userPreferencesBox.put(_localeKey, locale);

  bool get isBiometryEnabled =>
      (_userPreferencesBox.get(_biometryStatusKey, defaultValue: false) as bool?)!;

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

  Map<String, Permissions> get permissions => _permissionsBox
      .toMap()
      .cast<String, PermissionsDto>()
      .map((k, v) => MapEntry(k, v.toModel()));

  Future<void> setPermissions({
    required String origin,
    required Permissions permissions,
  }) =>
      _permissionsBox.put(origin, permissions.toDto());

  Future<void> deletePermissionsForOrigin(String origin) => _permissionsBox.delete(origin);

  Future<void> deletePermissionsForAccount(String address) async {
    final origins = permissions.entries
        .where((e) => e.value.accountInteraction?.address == address)
        .map((e) => e.key);

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
    final list =
        _externalAccountsBox.get(publicKey)?.cast<String>().where((e) => e != address).toList() ??
            [];

    list.add(address);

    await _externalAccountsBox.put(publicKey, list);
  }

  Future<void> removeExternalAccount({
    required String publicKey,
    required String address,
  }) async {
    final list =
        _externalAccountsBox.get(publicKey)?.cast<String>().where((e) => e != address).toList();

    if (list == null) return;

    if (list.isNotEmpty) {
      await _externalAccountsBox.put(publicKey, list);
    } else {
      await _externalAccountsBox.delete(publicKey);
    }
  }

  Future<void> clearExternalAccounts() => _externalAccountsBox.clear();

  List<Bookmark> get bookmarks => _bookmarksBox.values.map((e) => e.toModel()).toList();

  Future<void> putBookmark(Bookmark bookmark) => _bookmarksBox.put(bookmark.id, bookmark.toDto());

  Future<void> deleteBookmark(int id) => _bookmarksBox.delete(id);

  Future<void> clearBookmarks() => _bookmarksBox.clear();

  List<SearchHistoryDto> get searchHistory => _searchHistoryBox.values.toList();

  Future<void> addSearchHistoryEntry(SearchHistoryDto entry) async {
    var list = _searchHistoryBox.toMap().cast<String, SearchHistoryDto>().entries;

    list = list.where((e) => e.value.url != entry.url);

    final entries = [
      ...list,
      MapEntry(entry.openTime.toString(), entry),
    ]..sort((a, b) => -a.value.openTime.compareTo(b.value.openTime));

    await _searchHistoryBox.clear();

    await _searchHistoryBox.putAll(Map.fromEntries(entries.take(50)));
  }

  Future<void> removeSearchHistoryEntry(SearchHistoryDto entry) async {
    final keys = _searchHistoryBox
        .toMap()
        .cast<String, SearchHistoryDto>()
        .entries
        .where((e) => e.value.url == entry.url)
        .map((e) => e.key);

    for (final key in keys) {
      await _searchHistoryBox.delete(key);
    }
  }

  Future<void> clearSearchHistory() => _searchHistoryBox.clear();

  SiteMetaData? getSiteMetaData(String url) => _sitesMetaDataBox.get(url)?.toModel();

  Future<void> cacheSiteMetaData({
    required String url,
    required SiteMetaData metaData,
  }) =>
      _sitesMetaDataBox.put(url, metaData.toDto());

  Future<void> clearSitesMetaData() => _sitesMetaDataBox.clear();

  List<Currency> get currencies => _currenciesBox.values.map((e) => e.toModel()).toList();

  Future<void> saveCurrency({
    required String address,
    required Currency currency,
  }) =>
      _currenciesBox.put(address, currency.toDto());

  Future<void> clearCurrencies() => _currenciesBox.clear();

  bool get getWhyNeedBrowser => _browserNeedBox.get(_browserNeedKey) ?? false;

  Future<void> saveWhyNeedBrowser() => _browserNeedBox.put(_browserNeedKey, true);

  BrowserTabsDto get browserTabs =>
      _browserTabsBox.get(_browserTabsKey) ??
      const BrowserTabsDto(lastActiveTabIndex: -1, tabs: []);

  Future<void> saveBrowserTabs(BrowserTabsDto dto) => _browserTabsBox.put(_browserTabsKey, dto);

  Future<void> dispose() async {
    await _keysPasswordsBox.close();
    await _userPreferencesBox.close();
    await _systemTokenContractAssetsBox.close();
    await _customTokenContractAssetsBox.close();
    await _tonWalletInfosBox.close();
    await _tokenWalletInfosBox.close();
    await _tonWalletTransactionsBox.close();
    await _tokenWalletTransactionsBox.close();
    await _publicKeysLabelsBox.close();
    await _nekotonFlutterBox.close();
    await _preferencesBox.close();
    await _permissionsBox.close();
    await _externalAccountsBox.close();
    await _bookmarksBox.close();
    await _searchHistoryBox.close();
    await _sitesMetaDataBox.close();
    await _currenciesBox.close();
    await _browserNeedBox.close();
    await _browserTabsBox.close();
  }

  Future<void> _initialize() async {
    final hiveAesCipherKeyList =
        dotenv.env['HIVE_AES_CIPHER_KEY']?.split(' ').map((e) => int.parse(e)).toList();
    final hiveAesCipherKey =
        hiveAesCipherKeyList != null ? Uint8List.fromList(hiveAesCipherKeyList) : null;

    if (hiveAesCipherKey == null) {
      throw Exception('Provide HIVE_AES_CIPHER_KEY in .env file in correct format!');
    }

    _key = hiveAesCipherKey;

    await Hive.initFlutter();

    Hive
      ..tryRegisterAdapter(TokenContractAssetDtoAdapter())
      ..tryRegisterAdapter(WalletContractTypeDtoAdapter())
      ..tryRegisterAdapter(PermissionsDtoAdapter())
      ..tryRegisterAdapter(AccountInteractionDtoAdapter())
      ..tryRegisterAdapter(BookmarkDtoAdapter())
      ..tryRegisterAdapter(SiteMetaDataDtoAdapter())
      ..tryRegisterAdapter(CurrencyDtoAdapter())
      ..tryRegisterAdapter(TonWalletInfoDtoAdapter())
      ..tryRegisterAdapter(TokenWalletInfoDtoAdapter())
      ..tryRegisterAdapter(AccountStatusDtoAdapter())
      ..tryRegisterAdapter(ContractStateDtoAdapter())
      ..tryRegisterAdapter(DePoolOnRoundCompleteNotificationDtoAdapter())
      ..tryRegisterAdapter(DePoolReceiveAnswerNotificationDtoAdapter())
      ..tryRegisterAdapter(GenTimingsDtoAdapter())
      ..tryRegisterAdapter(LastTransactionIdDtoAdapter())
      ..tryRegisterAdapter(MessageDtoAdapter())
      ..tryRegisterAdapter(MultisigConfirmTransactionDtoAdapter())
      ..tryRegisterAdapter(MultisigSendTransactionDtoAdapter())
      ..tryRegisterAdapter(MultisigSubmitTransactionDtoAdapter())
      ..tryRegisterAdapter(MultisigTypeDtoAdapter())
      ..tryRegisterAdapter(SymbolDtoAdapter())
      ..tryRegisterAdapter(TokenIncomingTransferDtoAdapter())
      ..tryRegisterAdapter(TokenOutgoingTransferDtoAdapter())
      ..tryRegisterAdapter(TokenSwapBackDtoAdapter())
      ..tryRegisterAdapter(TokenWalletDeployedNotificationDtoAdapter())
      ..tryRegisterAdapter(TokenWalletTransactionWithDataDtoAdapter())
      ..tryRegisterAdapter(TonWalletDetailsDtoAdapter())
      ..tryRegisterAdapter(TonWalletTransactionWithDataDtoAdapter())
      ..tryRegisterAdapter(TransactionDtoAdapter())
      ..tryRegisterAdapter(TransactionIdDtoAdapter())
      ..tryRegisterAdapter(WalletInteractionInfoDtoAdapter())
      ..tryRegisterAdapter(WalletTypeDtoWalletV3Adapter())
      ..tryRegisterAdapter(WalletTypeDtoMultisigAdapter())
      ..tryRegisterAdapter(BrowserTabAdapter())
      ..tryRegisterAdapter(BrowserTabsDtoAdapter())
      ..tryRegisterAdapter(SearchHistoryDtoAdapter());

    _keysPasswordsBox =
        await Hive.openBox(_keysPasswordsBoxName, encryptionCipher: HiveAesCipher(_key));
    _userPreferencesBox = await Hive.openBox(_userPreferencesBoxName);
    _systemTokenContractAssetsBox = await Hive.openBox(_systemTokenContractAssetsBoxName);
    _customTokenContractAssetsBox = await Hive.openBox(_customTokenContractAssetsBoxName);
    _tonWalletInfosBox = await Hive.openBox(_tonWalletInfosBoxName);
    _tokenWalletInfosBox = await Hive.openBox(_tokenWalletInfosBoxName);
    _tonWalletTransactionsBox = await Hive.openBox(_tonWalletTransactionsBoxName);
    _tokenWalletTransactionsBox = await Hive.openBox(_tokenWalletTransactionsBoxName);
    _publicKeysLabelsBox = await Hive.openBox(_publicKeysLabelsBoxName);
    _nekotonFlutterBox = await Hive.openBox(_nekotonFlutterBoxName);
    _preferencesBox = await Hive.openBox(_preferencesBoxName);
    _permissionsBox = await Hive.openBox(_permissionsBoxName);
    _externalAccountsBox = await Hive.openBox(_externalAccountsBoxName);
    _bookmarksBox = await Hive.openBox(_bookmarksBoxName);
    _searchHistoryBox = await Hive.openBox(_searchHistoryBoxName);
    _sitesMetaDataBox = await Hive.openBox(_siteMetaDataBoxName);
    _currenciesBox = await Hive.openBox(_currenciesBoxName);
    _browserNeedBox = await Hive.openBox(_browserNeedKey);
    _browserTabsBox = await Hive.openBox(_browserTabsKey);

    await _migrateStorage();
  }

  Future<void> _migrateStorage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final file = File('${directory.path}/nekoton_storage.db');

      final content = await file.readAsString();

      final json = jsonDecode(content) as List<dynamic>;
      final map = json.cast<Map<String, dynamic>>().first.cast<String, String>();
      final keystoreDataStr = map[kKeystoreStorageKey];
      final accountsStorageDataStr = map[kAccountsStorageKey];

      if (keystoreDataStr != null) {
        final keystoreData = jsonDecode(keystoreDataStr) as String;
        await _nekotonFlutterBox.put(kKeystoreStorageKey, keystoreData);
      }

      if (accountsStorageDataStr != null) {
        final accountsStorageData = jsonDecode(accountsStorageDataStr) as String;
        await _nekotonFlutterBox.put(kAccountsStorageKey, accountsStorageData);
      }

      await file.delete();
    } catch (_) {}
  }
}

extension HiveInterfaceX on HiveInterface {
  void tryRegisterAdapter<T>(TypeAdapter<T> adapter) {
    if (!isAdapterRegistered(adapter.typeId)) registerAdapter(adapter);
  }
}
