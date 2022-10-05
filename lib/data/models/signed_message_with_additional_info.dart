import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'signed_message_with_additional_info.freezed.dart';

@freezed
class SignedMessageWithAdditionalInfo with _$SignedMessageWithAdditionalInfo {
  const factory SignedMessageWithAdditionalInfo({
    required SignedMessage message,
    String? dst,
    String? amount,
  }) = _SignedMessageWithAdditionalInfo;
}
