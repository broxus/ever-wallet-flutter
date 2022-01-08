import 'package:freezed_annotation/freezed_annotation.dart';

part 'ton_wallet_prepare_deploy_with_multiple_owners_params.freezed.dart';

@freezed
class TonWalletPrepareDeployWithMultipleOwnersParams with _$TonWalletPrepareDeployWithMultipleOwnersParams {
  factory TonWalletPrepareDeployWithMultipleOwnersParams({
    required String address,
    required List<String> custodians,
    required int reqConfirms,
  }) = _TonWalletPrepareDeployWithMultipleOwnersParams;
}
