import 'package:ever_wallet/data/models/contract_updates_subscription.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscribe_input.freezed.dart';
part 'subscribe_input.g.dart';

@freezed
class SubscribeInput with _$SubscribeInput {
  const factory SubscribeInput({
    required String address,
    required ContractUpdatesSubscription subscriptions,
  }) = _SubscribeInput;

  factory SubscribeInput.fromJson(Map<String, dynamic> json) => _$SubscribeInputFromJson(json);
}
