import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'token_wallet_deployed_notification_dto.freezed.dart';
part 'token_wallet_deployed_notification_dto.g.dart';

@freezedDto
class TokenWalletDeployedNotificationDto with _$TokenWalletDeployedNotificationDto {
  @HiveType(typeId: 26)
  const factory TokenWalletDeployedNotificationDto({
    @HiveField(0) required String rootTokenContract,
  }) = _TokenWalletDeployedNotificationDto;
}

extension TokenWalletDeployedNotificationX on TokenWalletDeployedNotification {
  TokenWalletDeployedNotificationDto toDto() => TokenWalletDeployedNotificationDto(
        rootTokenContract: rootTokenContract,
      );
}

extension TokenWalletDeployedNotificationDtoX on TokenWalletDeployedNotificationDto {
  TokenWalletDeployedNotification toModel() => TokenWalletDeployedNotification(
        rootTokenContract: rootTokenContract,
      );
}
