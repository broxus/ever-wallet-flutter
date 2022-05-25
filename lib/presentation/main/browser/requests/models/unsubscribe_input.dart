import 'package:freezed_annotation/freezed_annotation.dart';

part 'unsubscribe_input.freezed.dart';
part 'unsubscribe_input.g.dart';

@freezed
class UnsubscribeInput with _$UnsubscribeInput {
  const factory UnsubscribeInput({
    required String address,
  }) = _UnsubscribeInput;

  factory UnsubscribeInput.fromJson(Map<String, dynamic> json) => _$UnsubscribeInputFromJson(json);
}
