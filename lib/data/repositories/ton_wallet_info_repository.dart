import 'package:injectable/injectable.dart';

import '../../domain/models/ton_wallet_info.dart';
import '../dtos/ton_wallet_info_dto.dart';
import '../sources/local/hive_source.dart';

@lazySingleton
class TonWalletInfoRepository {
  final HiveSource _hiveSource;

  TonWalletInfoRepository(this._hiveSource);

  TonWalletInfo? get(String address) => _hiveSource.getTonWalletInfo(address)?.toModel();

  Future<void> save(TonWalletInfo tonWalletInfo) => _hiveSource.saveTonWalletInfo(tonWalletInfo.toDto());

  Future<void> remove(String address) => _hiveSource.removeTonWalletInfo(address);

  Future<void> clear() => _hiveSource.clearTonWalletInfos();
}
