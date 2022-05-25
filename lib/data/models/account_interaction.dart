import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import 'wallet_contract_type.dart';

part 'account_interaction.freezed.dart';
part 'account_interaction.g.dart';

@freezed
class AccountInteraction with _$AccountInteraction {
  @HiveType(typeId: 222)
  const factory AccountInteraction({
    @HiveField(0) required String address,
    @HiveField(1) required String publicKey,
    @HiveField(2) required WalletContractType contractType,
  }) = _AccountInteraction;

  factory AccountInteraction.fromJson(Map<String, dynamic> json) => _$AccountInteractionFromJson(json);
}
