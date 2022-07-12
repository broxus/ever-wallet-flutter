import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'de_pool_on_round_complete_notification_dto.freezed.dart';
part 'de_pool_on_round_complete_notification_dto.g.dart';

@freezedDto
class DePoolOnRoundCompleteNotificationDto with _$DePoolOnRoundCompleteNotificationDto {
  @HiveType(typeId: 7)
  const factory DePoolOnRoundCompleteNotificationDto({
    @HiveField(0) required String roundId,
    @HiveField(1) required String reward,
    @HiveField(2) required String ordinaryStake,
    @HiveField(3) required String vestingStake,
    @HiveField(4) required String lockStake,
    @HiveField(5) required bool reinvest,
    @HiveField(6) required int reason,
  }) = _DePoolOnRoundCompleteNotificationDto;
}

extension DePoolOnRoundCompleteNotificationX on DePoolOnRoundCompleteNotification {
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

extension DePoolOnRoundCompleteNotificationDtoX on DePoolOnRoundCompleteNotificationDto {
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
