import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../sources/local/hive_source.dart';

@lazySingleton
class TonWalletInfoRepository {
  final HiveSource _hiveSource;

  TonWalletInfoRepository(this._hiveSource);

  TonWalletInfo? get(String address) => _hiveSource.getTonWalletInfo(address);

  Future<void> save(TonWalletInfo tonWalletInfo) => _hiveSource.saveTonWalletInfo(tonWalletInfo);

  Future<void> remove(String address) => _hiveSource.removeTonWalletInfo(address);

  Future<void> clear() => _hiveSource.clearTonWalletInfos();
}