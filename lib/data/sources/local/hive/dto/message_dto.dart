import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'message_dto.freezed.dart';
part 'message_dto.g.dart';

@freezedDto
class MessageDto with _$MessageDto {
  @HiveType(typeId: 14)
  const factory MessageDto({
    @HiveField(0) required String hash,
    @HiveField(1) String? src,
    @HiveField(2) String? dst,
    @HiveField(3) required String value,
    @HiveField(4) required bool bounce,
    @HiveField(5) required bool bounced,
    @HiveField(6) String? body,
    @HiveField(7) String? bodyHash,
  }) = _MessageDto;
}

extension MessageX on Message {
  MessageDto toDto() => MessageDto(
        hash: hash,
        src: src,
        dst: dst,
        value: value,
        bounce: bounce,
        bounced: bounced,
        body: body,
        bodyHash: bodyHash,
      );
}

extension MessageDtoX on MessageDto {
  Message toModel() => Message(
        hash: hash,
        src: src,
        dst: dst,
        value: value,
        bounce: bounce,
        bounced: bounced,
        body: body,
        bodyHash: bodyHash,
      );
}
