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
import 'package:ever_wallet/data/sources/local/hive/dto/account_interaction_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/bookmark_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/currency_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/permissions_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/site_meta_data_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/token_contract_asset_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/wallet_contract_type_dto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

class HiveSource {
  final _keyPasswordsBoxName = 'keys_passwords_v1';
  final _userPreferencesBoxName = 'user_preferences_v1';
  final _systemTokenContractAssetsBoxName = 'system_token_contract_assets_v1';
  final _customTokenContractAssetsBoxName = 'custom_token_contract_assets_v1';
  final _keyLabelsBoxName = 'public_keys_labels_v1';
  final _seedsBoxName = 'seeds_v1';
  final _nekotonFlutterBoxName = 'nekoton_flutter';
  final _preferencesBoxName = 'nekoton_preferences';
  final _permissionsBoxName = 'nekoton_permissions_v1';
  final _externalAccountsBoxName = 'nekoton_external_accounts';
  final _bookmarksBoxName = 'bookmarks_box_v2';
  final _searchHistoryBoxName = 'search_history_v2';
  final _siteMetaDataBoxName = 'site_meta_data_v1';
  final _currenciesBoxName = 'currencies_v1';
  final _biometryStatusKey = 'biometry_status';
  final _currentKeyKey = 'current_public_key';
  final _currentConnectionKey = 'current_connection';
  final _localeKey = 'locale';
  final _browserNeedKey = 'browser_need_key';
  final _browserTabsKey = 'browser_tabs_key';
  final _browserTabsLastIndexKey = 'browser_tabs_last_index_key';

  HiveSource._();

  static Future<HiveSource> create() async {
    final instance = HiveSource._();
    await instance._initialize();
    return instance;
  }

  Box<String> get _keyPasswordsBox => Hive.box<String>(_keyPasswordsBoxName);

  Box<Object?> get _userPreferencesBox => Hive.box<Object?>(_userPreferencesBoxName);

  Box<TokenContractAssetDto> get _systemTokenContractAssetsBox =>
      Hive.box<TokenContractAssetDto>(_systemTokenContractAssetsBoxName);

  Box<TokenContractAssetDto> get _customTokenContractAssetsBox =>
      Hive.box<TokenContractAssetDto>(_customTokenContractAssetsBoxName);

  Box<String> get _keyLabelsBox => Hive.box<String>(_keyLabelsBoxName);

  Box<String> get _seedsBox => Hive.box<String>(_seedsBoxName);

  Box<String> get _nekotonFlutterBox => Hive.box<String>(_nekotonFlutterBoxName);

  Box<dynamic> get _preferencesBox => Hive.box<dynamic>(_preferencesBoxName);

  Box<PermissionsDto> get _permissionsBox => Hive.box<PermissionsDto>(_permissionsBoxName);

  Box<List> get _externalAccountsBox => Hive.box<List>(_externalAccountsBoxName);

  Box<BookmarkDto> get _bookmarksBox => Hive.box<BookmarkDto>(_bookmarksBoxName);

  Box<SearchHistoryDto> get _searchHistoryBox => Hive.box<SearchHistoryDto>(_searchHistoryBoxName);

  Box<SiteMetaDataDto> get _siteMetaDataBox => Hive.box<SiteMetaDataDto>(_siteMetaDataBoxName);

  Box<CurrencyDto> get _currenciesBox => Hive.box<CurrencyDto>(_currenciesBoxName);

  Box<dynamic> get _browserTabsBox => Hive.box<dynamic>(_browserTabsKey);

  Stream<Map<String, String>> get seedsStream =>
      _seedsBox.watchAll().map((e) => e.cast<String, String>());

  Map<String, String> get seeds => _seedsBox.toMap().cast<String, String>();

  Future<void> addSeed({
    required String masterKey,
    required String name,
  }) =>
      _seedsBox.put(masterKey, name);

  Future<void> removeSeed(String masterKey) => _seedsBox.delete(masterKey);

  Future<void> clearSeeds() => _seedsBox.clear();

  Stream<String?> get currentKeyStream => _preferencesBox.watchKey(_currentKeyKey).cast<String?>();

  String? get currentKey => _preferencesBox.get(_currentKeyKey) as String?;

  Future<void> setCurrentKey(String? publicKey) => _preferencesBox.put(
        _currentKeyKey,
        publicKey,
      );

  Stream<Map<String, String>> get keyLabelsStream =>
      _keyLabelsBox.watchAll().map((e) => e.cast<String, String>());

  Map<String, String> get keyLabels => _keyLabelsBox.toMap().cast<String, String>();

  Future<void> setKeyLabel({
    required String publicKey,
    required String label,
  }) =>
      _keyLabelsBox.put(publicKey, label);

  Future<void> removeKeyLabel(String publicKey) => _keyLabelsBox.delete(publicKey);

  Future<void> clearKeyLabels() => _keyLabelsBox.clear();

  String? getKeyPassword(String publicKey) => _keyPasswordsBox.get(publicKey);

  Future<void> setKeyPassword({
    required String publicKey,
    required String password,
  }) =>
      _keyPasswordsBox.put(publicKey, password);

  Future<void> removeKeyPassword(String publicKey) => _keyPasswordsBox.delete(publicKey);

  Future<void> clearKeyPasswords() => _keyPasswordsBox.clear();

  Stream<Map<String, List<String>>> get externalAccountsStream => _externalAccountsBox
      .watchAll()
      .map((e) => e.map((k, v) => MapEntry(k as String, v.cast<String>())));

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

  String? get currentConnection => _preferencesBox.get(_currentConnectionKey) as String?;

  Future<void> setCurrentConnection(String currentConnection) => _preferencesBox.put(
        _currentConnectionKey,
        currentConnection,
      );

  Future<String?> getStorageData(String key) async => _nekotonFlutterBox.get(key);

  Future<void> setStorageData({
    required String key,
    required String value,
  }) =>
      _nekotonFlutterBox.put(key, value);

  Future<void> removeStorageData(String key) => _nekotonFlutterBox.delete(key);

  Stream<List<TokenContractAsset>> get systemTokenContractAssetsStream =>
      _systemTokenContractAssetsBox.watchAllValues().map((e) => e.map((e) => e.toModel()).toList());

  List<TokenContractAsset> get systemTokenContractAssets =>
      _systemTokenContractAssetsBox.values.map((e) => e.toModel()).toList();

  Future<void> updateSystemTokenContractAssets(List<TokenContractAsset> assets) async {
    await _systemTokenContractAssetsBox.clear();
    await _systemTokenContractAssetsBox.addAll(assets.map((e) => e.toDto()));
  }

  Stream<List<TokenContractAsset>> get customTokenContractAssetsStream =>
      _customTokenContractAssetsBox.watchAllValues().map((e) => e.map((e) => e.toModel()).toList());

  List<TokenContractAsset> get customTokenContractAssets =>
      _customTokenContractAssetsBox.values.map((e) => e.toModel()).toList();

  Future<void> addCustomTokenContractAsset(TokenContractAsset tokenContractAsset) =>
      _customTokenContractAssetsBox.put(tokenContractAsset.address, tokenContractAsset.toDto());

  Future<void> removeCustomTokenContractAsset(String address) =>
      _customTokenContractAssetsBox.delete(address);

  Future<void> clearCustomTokenContractAssets() => _customTokenContractAssetsBox.clear();

  Stream<String?> get localeStream => _userPreferencesBox.watchKey(_localeKey).cast<String?>();

  String? get locale => _userPreferencesBox.get(_localeKey) as String?;

  Future<void> setLocale(String locale) => _userPreferencesBox.put(_localeKey, locale);

  Future<void> clearLocale() => _userPreferencesBox.delete(_localeKey);

  Stream<bool> get isBiometryEnabledStream =>
      _userPreferencesBox.watchKey(_biometryStatusKey).cast<bool?>().map((e) => e ?? false);

  bool get isBiometryEnabled => _userPreferencesBox.get(_biometryStatusKey) as bool? ?? false;

  Future<void> setIsBiometryEnabled(bool isEnabled) =>
      _userPreferencesBox.put(_biometryStatusKey, isEnabled);

  Future<void> clearIsBiometryEnabled() => _userPreferencesBox.delete(_biometryStatusKey);

  Stream<Map<String, Permissions>> get permissionsStream => _permissionsBox
      .watchAll()
      .cast<Map<String, PermissionsDto>>()
      .map((e) => e.map((k, v) => MapEntry(k, v.toModel())));

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

  Stream<List<Bookmark>> get bookmarksStream =>
      _bookmarksBox.watchAllValues().map((e) => e.map((e) => e.toModel()).toList());

  List<Bookmark> get bookmarks => _bookmarksBox.values.map((e) => e.toModel()).toList();

  Future<void> addBookmark(Bookmark bookmark) => _bookmarksBox.put(bookmark.id, bookmark.toDto());

  Future<void> deleteBookmark(int id) => _bookmarksBox.delete(id);

  Future<void> clearBookmarks() => _bookmarksBox.clear();

  Stream<List<SearchHistoryDto>> get searchHistoryStream =>
      _searchHistoryBox.watchAllValues().map((e) => e.toList());

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

  SiteMetaData? getSiteMetaData(String url) => _siteMetaDataBox.get(url)?.toModel();

  Future<void> cacheSiteMetaData({
    required String url,
    required SiteMetaData metaData,
  }) =>
      _siteMetaDataBox.put(url, metaData.toDto());

  Future<void> clearSitesMetaData() => _siteMetaDataBox.clear();

  Stream<List<Currency>> get currenciesStream =>
      _currenciesBox.watchAllValues().map((e) => e.map((e) => e.toModel()).toList());

  List<Currency> get currencies => _currenciesBox.values.map((e) => e.toModel()).toList();

  Future<void> saveCurrency({
    required String address,
    required Currency currency,
  }) =>
      _currenciesBox.put(address, currency.toDto());

  Future<void> clearCurrencies() => _currenciesBox.clear();

  bool get getWhyNeedBrowser => _preferencesBox.get(_browserNeedKey) as bool? ?? false;

  Future<void> saveWhyNeedBrowser() => _preferencesBox.put(_browserNeedKey, true);

  List<BrowserTab> get browserTabs =>
      (_browserTabsBox.get(_browserTabsKey) as List<dynamic>?)?.cast<BrowserTab>() ??
      <BrowserTab>[];

  int get browserTabsLastIndex => _browserTabsBox.get(_browserTabsLastIndexKey) as int? ?? -1;

  Future<void> saveBrowserTabs(List<BrowserTab> dto) => _browserTabsBox.put(_browserTabsKey, dto);

  Future<void> saveBrowserTabsLastIndex(int lastIndex) =>
      _browserTabsBox.put(_browserTabsLastIndexKey, lastIndex);

  Future<void> dispose() => Hive.close();

  Future<void> _initialize() async {
    final key = Uint8List.fromList(
      [
        142,
        201,
        97,
        67,
        9,
        207,
        25,
        19,
        205,
        112,
        165,
        64,
        130,
        45,
        105,
        15,
        199,
        146,
        22,
        64,
        34,
        45,
        150,
        200,
        199,
        63,
        145,
        56,
        34,
        80,
        128,
        80
      ],
    );

    await Hive.initFlutter();

    Hive
      ..tryRegisterAdapter(TokenContractAssetDtoAdapter())
      ..tryRegisterAdapter(WalletContractTypeDtoAdapter())
      ..tryRegisterAdapter(PermissionsDtoAdapter())
      ..tryRegisterAdapter(AccountInteractionDtoAdapter())
      ..tryRegisterAdapter(BookmarkDtoAdapter())
      ..tryRegisterAdapter(SiteMetaDataDtoAdapter())
      ..tryRegisterAdapter(CurrencyDtoAdapter())
      ..tryRegisterAdapter(BrowserTabAdapter())
      ..tryRegisterAdapter(SearchHistoryDtoAdapter())
      ..tryRegisterAdapter(CurrencyDtoAdapter());

    await Hive.openBox<String>(_keyPasswordsBoxName, encryptionCipher: HiveAesCipher(key));
    await Hive.openBox<Object?>(_userPreferencesBoxName);
    await Hive.openBox<TokenContractAssetDto>(_systemTokenContractAssetsBoxName);
    await Hive.openBox<TokenContractAssetDto>(_customTokenContractAssetsBoxName);
    await Hive.openBox<String>(_keyLabelsBoxName);
    await Hive.openBox<String>(_seedsBoxName);
    await Hive.openBox<String>(_nekotonFlutterBoxName);
    await Hive.openBox<dynamic>(_preferencesBoxName);
    await Hive.openBox<PermissionsDto>(_permissionsBoxName);
    await Hive.openBox<List>(_externalAccountsBoxName);
    await Hive.openBox<BookmarkDto>(_bookmarksBoxName);
    await Hive.openBox<String>(_searchHistoryBoxName);
    await Hive.openBox<SiteMetaDataDto>(_siteMetaDataBoxName);
    await Hive.openBox<CurrencyDto>(_currenciesBoxName);
    await Hive.openBox<bool>(_browserNeedKey);
    await Hive.openBox<dynamic>(_browserTabsKey);

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

extension<T> on Box<T> {
  Stream<T?> watchKey(dynamic key) =>
      watch(key: key).map((e) => e.value as T).cast<T?>().startWith(get(key));

  Stream<Map<dynamic, T>> watchAll() => watch().map((_) => toMap()).startWith(toMap());

  Stream<Iterable<T>> watchAllValues() => watch().map((_) => values).startWith(values);
}

extension on HiveInterface {
  void tryRegisterAdapter<T>(TypeAdapter<T> adapter) {
    if (!isAdapterRegistered(adapter.typeId)) registerAdapter(adapter);
  }
}
