import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'token_wallet_info.freezed.dart';
part 'token_wallet_info.g.dart';

@freezed
class TokenWalletInfo with _$TokenWalletInfo {
  @HiveType(typeId: 210)
  const factory TokenWalletInfo({
    @HiveField(0) required String owner,
    @HiveField(1) required String address,
    @HiveField(2) required Symbol symbol,
    @HiveField(3) required TokenWalletVersion version,
    @HiveField(4) required String balance,
    @HiveField(5) required ContractState contractState,
  }) = _TokenWalletInfo;

  factory TokenWalletInfo.fromJson(Map<String, dynamic> json) => _$TokenWalletInfoFromJson(json);
}
