import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'message_dto.freezed.dart';
part 'message_dto.g.dart';

@freezed
class MessageDto with _$MessageDto {
  @HiveType(typeId: 11)
  const factory MessageDto({
    @HiveField(0) String? src,
    @HiveField(1) String? dst,
    @HiveField(2) required String value,
    @HiveField(3) required bool bounce,
    @HiveField(4) required bool bounced,
    @HiveField(5) String? body,
    @HiveField(6) String? bodyHash,
  }) = _MessageDto;
}

extension MessageDtoToDomain on MessageDto {
  Message toModel() => Message(
        src: src,
        dst: dst,
        value: value,
        bounce: bounce,
        bounced: bounced,
        body: body,
        bodyHash: bodyHash,
      );
}

extension MessageFromDomain on Message {
  MessageDto toDto() => MessageDto(
        src: src,
        dst: dst,
        value: value,
        bounce: bounce,
        bounced: bounced,
        body: body,
        bodyHash: bodyHash,
      );
}
