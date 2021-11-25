import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import 'multisig_transaction_dto.dart';

part 'wallet_interaction_method_dto.freezed.dart';
part 'wallet_interaction_method_dto.g.dart';

@freezed
class WalletInteractionMethodDto with _$WalletInteractionMethodDto {
  @HiveType(typeId: 49)
  const factory WalletInteractionMethodDto.walletV3Transfer() = _WalletV3Transfer;

  @HiveType(typeId: 50)
  const factory WalletInteractionMethodDto.multisig({
    @HiveField(0) required MultisigTransactionDto multisigTransaction,
  }) = _Multisig;

  factory WalletInteractionMethodDto.fromJson(Map<String, dynamic> json) => _$WalletInteractionMethodDtoFromJson(json);
}

extension WalletInteractionMethodDtoToDomain on WalletInteractionMethodDto {
  WalletInteractionMethod toModel() => when(
        walletV3Transfer: () => const WalletInteractionMethod.walletV3Transfer(),
        multisig: (multisigTransaction) => WalletInteractionMethod.multisig(
          multisigTransaction: multisigTransaction.toModel(),
        ),
      );
}

extension WalletInteractionMethodFromDomain on WalletInteractionMethod {
  WalletInteractionMethodDto toDto() => when(
        walletV3Transfer: () => const WalletInteractionMethodDto.walletV3Transfer(),
        multisig: (multisigTransaction) => WalletInteractionMethodDto.multisig(
          multisigTransaction: multisigTransaction.toDto(),
        ),
      );
}
