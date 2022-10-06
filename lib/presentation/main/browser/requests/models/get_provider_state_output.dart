import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../data/models/contract_updates_subscription.dart';
import '../../../../../data/models/permission.dart';
import '../../../../../data/models/permissions.dart';

part 'get_provider_state_output.freezed.dart';
part 'get_provider_state_output.g.dart';

@freezed
class GetProviderStateOutput with _$GetProviderStateOutput {
  @JsonSerializable(explicitToJson: true)
  const factory GetProviderStateOutput({
    required String version,
    required int numericVersion,
    required String selectedConnection,
    required int networkId,
    required List<Permission> supportedPermissions,
    required Permissions permissions,
    required Map<String, ContractUpdatesSubscription> subscriptions,
  }) = _GetProviderStateOutput;

  factory GetProviderStateOutput.fromJson(Map<String, dynamic> json) => _$GetProviderStateOutputFromJson(json);
}
