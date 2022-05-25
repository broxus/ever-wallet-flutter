import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../data/models/contract_updates_subscription.dart';

part 'subscribe_input.freezed.dart';
part 'subscribe_input.g.dart';

@freezed
class SubscribeInput with _$SubscribeInput {
  @JsonSerializable(explicitToJson: true)
  const factory SubscribeInput({
    required String address,
    required ContractUpdatesSubscription subscriptions,
  }) = _SubscribeInput;

  factory SubscribeInput.fromJson(Map<String, dynamic> json) => _$SubscribeInputFromJson(json);
}
