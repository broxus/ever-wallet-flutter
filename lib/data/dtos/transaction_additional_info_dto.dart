import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import 'de_pool_on_round_complete_notification_dto.dart';
import 'de_pool_receive_answer_notification_dto.dart';
import 'eth_event_status_dto.dart';
import 'token_wallet_deployed_notification_dto.dart';
import 'ton_event_status_dto.dart';
import 'wallet_interaction_info_dto.dart';

part 'transaction_additional_info_dto.freezed.dart';
part 'transaction_additional_info_dto.g.dart';

@freezed
class TransactionAdditionalInfoDto with _$TransactionAdditionalInfoDto {
  @HiveType(typeId: 41)
  const factory TransactionAdditionalInfoDto.comment({
    @HiveField(0) required String value,
  }) = _CommentDto;

  @HiveType(typeId: 42)
  const factory TransactionAdditionalInfoDto.dePoolOnRoundComplete({
    @HiveField(0) required DePoolOnRoundCompleteNotificationDto notification,
  }) = _DePoolOnRoundCompleteDto;

  @HiveType(typeId: 43)
  const factory TransactionAdditionalInfoDto.dePoolReceiveAnswer({
    @HiveField(0) required DePoolReceiveAnswerNotificationDto notification,
  }) = _DePoolReceiveAnswerDto;

  @HiveType(typeId: 44)
  const factory TransactionAdditionalInfoDto.tokenWalletDeployed({
    @HiveField(0) required TokenWalletDeployedNotificationDto notification,
  }) = _TokenWalletDeployedDto;

  @HiveType(typeId: 45)
  const factory TransactionAdditionalInfoDto.ethEventStatusChanged({
    @HiveField(0) required EthEventStatusDto status,
  }) = _EthEventStatusChangedDto;

  @HiveType(typeId: 46)
  const factory TransactionAdditionalInfoDto.tonEventStatusChanged({
    @HiveField(0) required TonEventStatusDto status,
  }) = _TonEventStatusChangedDto;

  @HiveType(typeId: 47)
  const factory TransactionAdditionalInfoDto.walletInteraction({
    @HiveField(0) required WalletInteractionInfoDto info,
  }) = _WalletInteractionDto;
}

extension TransactionAdditionalInfoDtoToDomain on TransactionAdditionalInfoDto {
  TransactionAdditionalInfo toModel() => when(
        comment: (value) => TransactionAdditionalInfo.comment(
          value: value,
        ),
        dePoolOnRoundComplete: (notification) => TransactionAdditionalInfo.dePoolOnRoundComplete(
          notification: notification.toModel(),
        ),
        dePoolReceiveAnswer: (notification) => TransactionAdditionalInfo.dePoolReceiveAnswer(
          notification: notification.toModel(),
        ),
        tokenWalletDeployed: (notification) => TransactionAdditionalInfo.tokenWalletDeployed(
          notification: notification.toModel(),
        ),
        ethEventStatusChanged: (status) => TransactionAdditionalInfo.ethEventStatusChanged(
          status: status.toModel(),
        ),
        tonEventStatusChanged: (status) => TransactionAdditionalInfo.tonEventStatusChanged(
          status: status.toModel(),
        ),
        walletInteraction: (info) => TransactionAdditionalInfo.walletInteraction(
          info: info.toModel(),
        ),
      );
}

extension TransactionAdditionalInfoFromDomain on TransactionAdditionalInfo {
  TransactionAdditionalInfoDto toDto() => when(
        comment: (value) => TransactionAdditionalInfoDto.comment(
          value: value,
        ),
        dePoolOnRoundComplete: (notification) => TransactionAdditionalInfoDto.dePoolOnRoundComplete(
          notification: notification.toDto(),
        ),
        dePoolReceiveAnswer: (notification) => TransactionAdditionalInfoDto.dePoolReceiveAnswer(
          notification: notification.toDto(),
        ),
        tokenWalletDeployed: (notification) => TransactionAdditionalInfoDto.tokenWalletDeployed(
          notification: notification.toDto(),
        ),
        ethEventStatusChanged: (status) => TransactionAdditionalInfoDto.ethEventStatusChanged(
          status: status.toDto(),
        ),
        tonEventStatusChanged: (status) => TransactionAdditionalInfoDto.tonEventStatusChanged(
          status: status.toDto(),
        ),
        walletInteraction: (info) => TransactionAdditionalInfoDto.walletInteraction(
          info: info.toDto(),
        ),
      );
}
