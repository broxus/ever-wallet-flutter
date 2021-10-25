import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../dtos/bookmark_dto.dart';
import '../../dtos/token_contract_asset_dto.dart';

@preResolve
@lazySingleton
class HiveSource {
  late final Uint8List _key;
  final _biometryStatus = "biometry_status";
  late final Box<TokenContractAssetDto> _tokenContractAssetsBox;
  late final Box<BookmarkDto> _bookmarksBox;
  late final Box<Object?> _biometryPreferencesBox;
  late final Box<String> _walletsPasswordsBox;
  static const _bookmarksPreset = [
    BookmarkDto(
      url: "https://wton.io/",
      title: "WTON",
      icon: "https://wton.io/favicon.ico",
    ),
    BookmarkDto(
      url: "https://tonswap.io/swap",
      title: "TON Swap",
      icon: "https://tonswap.io/favicon.svg",
    ),
    BookmarkDto(
      url: "https://tonscan.io/",
      title: "Free TON Blockchain Explorer",
      icon: "https://tonscan.io/assets/favicon/favicon-32x32.png",
    ),
  ];

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

    final bookmarksBoxExists = await Hive.boxExists("bookmarks");

    hiveSource._tokenContractAssetsBox = await Hive.openBox<TokenContractAssetDto>("token_contract_assets");
    hiveSource._bookmarksBox = await Hive.openBox<BookmarkDto>("bookmarks");
    hiveSource._biometryPreferencesBox = await Hive.openBox<Object?>("biometry_preferences");
    hiveSource._walletsPasswordsBox = await Hive.openBox<String>(
      "wallets_passwords_v2",
      encryptionCipher: HiveAesCipher(hiveSource._key),
    );

    if (!bookmarksBoxExists) {
      for (final item in _bookmarksPreset) {
        await hiveSource.addBookmark(item);
      }
    }

    return hiveSource;
  }

  List<BookmarkDto> getBookmarks() => _bookmarksBox.values.toList();

  Future<void> addBookmark(BookmarkDto bookmark) async {
    final old = _bookmarksBox.toMap().entries.firstWhereOrNull((e) => e.value.url == bookmark.url);

    if (old != null) {
      await _bookmarksBox.put(old.key, bookmark);
    } else {
      await _bookmarksBox.add(bookmark);
    }
  }

  Future<void> updateBookmark(BookmarkDto bookmark) async {
    final old = _bookmarksBox.toMap().entries.firstWhereOrNull((e) => e.value.url == bookmark.url);

    if (old == null) {
      throw Exception();
    }

    await _bookmarksBox.put(old.key, bookmark);
  }

  Future<void> removeBookmark(BookmarkDto bookmark) async {
    final old = _bookmarksBox.toMap().entries.firstWhereOrNull((e) => e.value.url == bookmark.url);

    if (old == null) {
      throw Exception();
    }

    await _bookmarksBox.delete(old.key);
  }

  Future<void> clearBookmarks() async => _bookmarksBox.clear();

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

  Future<String?> get(String publicKey) async {
    return _walletsPasswordsBox.get(publicKey);
  }

  Future<void> clearPasswords() async {
    await _walletsPasswordsBox.clear();
  }
}
