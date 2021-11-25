import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'de_pool_on_round_complete_notification_dto.freezed.dart';
part 'de_pool_on_round_complete_notification_dto.g.dart';

@freezed
class DePoolOnRoundCompleteNotificationDto with _$DePoolOnRoundCompleteNotificationDto {
  @HiveType(typeId: 26)
  const factory DePoolOnRoundCompleteNotificationDto({
    @HiveField(0) required String roundId,
    @HiveField(1) required String reward,
    @HiveField(2) required String ordinaryStake,
    @HiveField(3) required String vestingStake,
    @HiveField(4) required String lockStake,
    @HiveField(5) required bool reinvest,
    @HiveField(6) required int reason,
  }) = _DePoolOnRoundCompleteNotificationDto;

  factory DePoolOnRoundCompleteNotificationDto.fromJson(Map<String, dynamic> json) =>
      _$DePoolOnRoundCompleteNotificationDtoFromJson(json);
}

extension DePoolOnRoundCompleteNotificationDtoToDomain on DePoolOnRoundCompleteNotificationDto {
  DePoolOnRoundCompleteNotification toModel() => DePoolOnRoundCompleteNotification(
        roundId: roundId,
        reward: reward,
        ordinaryStake: ordinaryStake,
        vestingStake: vestingStake,
        lockStake: lockStake,
        reinvest: reinvest,
        reason: reason,
      );
}

extension DePoolOnRoundCompleteNotificationFromDomain on DePoolOnRoundCompleteNotification {
  DePoolOnRoundCompleteNotificationDto toDto() => DePoolOnRoundCompleteNotificationDto(
        roundId: roundId,
        reward: reward,
        ordinaryStake: ordinaryStake,
        vestingStake: vestingStake,
        lockStake: lockStake,
        reinvest: reinvest,
        reason: reason,
      );
}
