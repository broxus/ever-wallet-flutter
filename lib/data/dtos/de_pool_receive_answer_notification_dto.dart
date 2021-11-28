import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'de_pool_receive_answer_notification_dto.freezed.dart';
part 'de_pool_receive_answer_notification_dto.g.dart';

@freezed
class DePoolReceiveAnswerNotificationDto with _$DePoolReceiveAnswerNotificationDto {
  @HiveType(typeId: 27)
  const factory DePoolReceiveAnswerNotificationDto({
    @HiveField(0) required int errorCode,
    @HiveField(1) required String comment,
  }) = _DePoolReceiveAnswerNotificationDto;

  factory DePoolReceiveAnswerNotificationDto.fromJson(Map<String, dynamic> json) =>
      _$DePoolReceiveAnswerNotificationDtoFromJson(json);
}

extension DePoolReceiveAnswerNotificationDtoToDomain on DePoolReceiveAnswerNotificationDto {
  DePoolReceiveAnswerNotification toModel() => DePoolReceiveAnswerNotification(
        errorCode: errorCode,
        comment: comment,
      );
}

extension DePoolReceiveAnswerNotificationFromDomain on DePoolReceiveAnswerNotification {
  DePoolReceiveAnswerNotificationDto toDto() => DePoolReceiveAnswerNotificationDto(
        errorCode: errorCode,
        comment: comment,
      );
}
