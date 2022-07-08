import 'package:ever_wallet/data/sources/local/hive/dto/de_pool_on_round_complete_notification_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/de_pool_receive_answer_notification_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/token_wallet_deployed_notification_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/wallet_interaction_info_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'transaction_additional_info_dto.freezed.dart';
part 'transaction_additional_info_dto.g.dart';

@freezedDto
class TransactionAdditionalInfoDto with _$TransactionAdditionalInfoDto {
  @HiveType(typeId: 39)
  const factory TransactionAdditionalInfoDto.comment(@HiveField(0) String data) =
      _TransactionAdditionalInfoDtoComment;

  @HiveType(typeId: 40)
  const factory TransactionAdditionalInfoDto.dePoolOnRoundComplete(
    @HiveField(0) DePoolOnRoundCompleteNotificationDto data,
  ) = _TransactionAdditionalInfoDtoDePoolOnRoundComplete;

  @HiveType(typeId: 41)
  const factory TransactionAdditionalInfoDto.dePoolReceiveAnswer(
    @HiveField(0) DePoolReceiveAnswerNotificationDto data,
  ) = _TransactionAdditionalInfoDtoDePoolReceiveAnswer;

  @HiveType(typeId: 42)
  const factory TransactionAdditionalInfoDto.tokenWalletDeployed(
    @HiveField(0) TokenWalletDeployedNotificationDto data,
  ) = _TransactionAdditionalInfoDtoTokenWalletDeployed;

  @HiveType(typeId: 43)
  const factory TransactionAdditionalInfoDto.walletInteraction(
    @HiveField(0) WalletInteractionInfoDto data,
  ) = _TransactionAdditionalInfoDtoWalletInteraction;
}

extension TransactionAdditionalInfoX on TransactionAdditionalInfo {
  TransactionAdditionalInfoDto toDto() => when(
        comment: (data) => TransactionAdditionalInfoDto.comment(data),
        dePoolOnRoundComplete: (data) =>
            TransactionAdditionalInfoDto.dePoolOnRoundComplete(data.toDto()),
        dePoolReceiveAnswer: (data) =>
            TransactionAdditionalInfoDto.dePoolReceiveAnswer(data.toDto()),
        tokenWalletDeployed: (data) =>
            TransactionAdditionalInfoDto.tokenWalletDeployed(data.toDto()),
        walletInteraction: (data) => TransactionAdditionalInfoDto.walletInteraction(data.toDto()),
      );
}

extension TransactionAdditionalInfoDtoX on TransactionAdditionalInfoDto {
  TransactionAdditionalInfo toModel() => when(
        comment: (data) => TransactionAdditionalInfo.comment(data),
        dePoolOnRoundComplete: (data) =>
            TransactionAdditionalInfo.dePoolOnRoundComplete(data.toModel()),
        dePoolReceiveAnswer: (data) =>
            TransactionAdditionalInfo.dePoolReceiveAnswer(data.toModel()),
        tokenWalletDeployed: (data) =>
            TransactionAdditionalInfo.tokenWalletDeployed(data.toModel()),
        walletInteraction: (data) => TransactionAdditionalInfo.walletInteraction(data.toModel()),
      );
}
