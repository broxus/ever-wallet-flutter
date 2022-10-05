import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'unsigned_message_with_additional_info.freezed.dart';

@freezed
class UnsignedMessageWithAdditionalInfo with _$UnsignedMessageWithAdditionalInfo {
  const factory UnsignedMessageWithAdditionalInfo({
    required UnsignedMessage message,
    String? dst,
    String? amount,
  }) = _UnsignedMessageWithAdditionalInfo;
}
