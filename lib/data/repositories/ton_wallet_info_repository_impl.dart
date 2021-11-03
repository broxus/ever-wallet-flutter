import 'package:injectable/injectable.dart';

import '../../domain/models/ton_wallet_info.dart';
import '../../domain/repositories/ton_wallet_info_repository.dart';
import '../dtos/ton_wallet_info_dto.dart';
import '../sources/local/hive_source.dart';

@LazySingleton(as: TonWalletInfoRepository)
class TonWalletInfoRepositoryImpl implements TonWalletInfoRepository {
  final HiveSource _hiveSource;

  TonWalletInfoRepositoryImpl(this._hiveSource);

  @override
  TonWalletInfo? get(String address) => _hiveSource.getTonWalletInfo(address)?.toModel();

  @override
  Future<void> save(TonWalletInfo tonWalletInfo) => _hiveSource.saveTonWalletInfo(tonWalletInfo.toDto());

  @override
  Future<void> remove(String address) => _hiveSource.removeTonWalletInfo(address);

  @override
  Future<void> clear() => _hiveSource.clearTonWalletInfos();
}
