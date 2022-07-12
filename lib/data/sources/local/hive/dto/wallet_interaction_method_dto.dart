import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/multisig_transaction_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'wallet_interaction_method_dto.freezed.dart';
part 'wallet_interaction_method_dto.g.dart';

@freezedDto
class WalletInteractionMethodDto with _$WalletInteractionMethodDto {
  @HiveType(typeId: 49)
  const factory WalletInteractionMethodDto.walletV3Transfer() =
      _WalletInteractionMethodDtoWalletV3Transfer;

  @HiveType(typeId: 50)
  const factory WalletInteractionMethodDto.multisig(@HiveField(0) MultisigTransactionDto data) =
      _WalletInteractionMethodDtoMultisig;
}

extension WalletInteractionMethodX on WalletInteractionMethod {
  WalletInteractionMethodDto toDto() => when(
        walletV3Transfer: () => const WalletInteractionMethodDto.walletV3Transfer(),
        multisig: (data) => WalletInteractionMethodDto.multisig(data.toDto()),
      );
}

extension WalletInteractionMethodDtoX on WalletInteractionMethodDto {
  WalletInteractionMethod toModel() => when(
        walletV3Transfer: () => const WalletInteractionMethod.walletV3Transfer(),
        multisig: (data) => WalletInteractionMethod.multisig(data.toModel()),
      );
}
