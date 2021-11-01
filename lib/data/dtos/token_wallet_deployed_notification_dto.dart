import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'token_wallet_deployed_notification_dto.freezed.dart';
part 'token_wallet_deployed_notification_dto.g.dart';

@freezed
class TokenWalletDeployedNotificationDto with _$TokenWalletDeployedNotificationDto {
  @HiveType(typeId: 38)
  const factory TokenWalletDeployedNotificationDto({
    @HiveField(0) required String rootTokenContract,
  }) = _TokenWalletDeployedNotificationDto;
}

extension TokenWalletDeployedNotificationDtoToDomain on TokenWalletDeployedNotificationDto {
  TokenWalletDeployedNotification toModel() => TokenWalletDeployedNotification(
        rootTokenContract: rootTokenContract,
      );
}

extension TokenWalletDeployedNotificationFromDomain on TokenWalletDeployedNotification {
  TokenWalletDeployedNotificationDto toDto() => TokenWalletDeployedNotificationDto(
        rootTokenContract: rootTokenContract,
      );
}
