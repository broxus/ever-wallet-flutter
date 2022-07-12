import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'de_pool_receive_answer_notification_dto.freezed.dart';
part 'de_pool_receive_answer_notification_dto.g.dart';

@freezedDto
class DePoolReceiveAnswerNotificationDto with _$DePoolReceiveAnswerNotificationDto {
  @HiveType(typeId: 8)
  const factory DePoolReceiveAnswerNotificationDto({
    @HiveField(0) required int errorCode,
    @HiveField(1) required String comment,
  }) = _DePoolReceiveAnswerNotificationDto;
}

extension DePoolReceiveAnswerNotificationX on DePoolReceiveAnswerNotification {
  DePoolReceiveAnswerNotificationDto toDto() => DePoolReceiveAnswerNotificationDto(
        errorCode: errorCode,
        comment: comment,
      );
}

extension DePoolReceiveAnswerNotificationDtoX on DePoolReceiveAnswerNotificationDto {
  DePoolReceiveAnswerNotification toModel() => DePoolReceiveAnswerNotification(
        errorCode: errorCode,
        comment: comment,
      );
}
