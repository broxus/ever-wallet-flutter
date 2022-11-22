import 'package:ever_wallet/data/models/contract_updates_subscription.dart';
import 'package:ever_wallet/data/models/permission.dart';
import 'package:ever_wallet/data/models/permissions.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_provider_state_output.freezed.dart';
part 'get_provider_state_output.g.dart';

@freezed
class GetProviderStateOutput with _$GetProviderStateOutput {
  const factory GetProviderStateOutput({
    required String version,
    required int numericVersion,
    required String selectedConnection,
    required int networkId,
    required List<Permission> supportedPermissions,
    required Permissions permissions,
    required Map<String, ContractUpdatesSubscription> subscriptions,
  }) = _GetProviderStateOutput;

  factory GetProviderStateOutput.fromJson(Map<String, dynamic> json) =>
      _$GetProviderStateOutputFromJson(json);
}
