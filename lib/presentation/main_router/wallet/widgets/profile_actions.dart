import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/blocs/account/account_info_bloc.dart';
import '../../../../domain/blocs/ton_wallet/ton_wallet_info_bloc.dart';
import '../../../../injection.dart';
import '../../../design/design.dart';
import '../../../design/widget/crystal_bottom_sheet.dart';
import '../modals/add_asset_flow/add_asset_modal.dart';
import '../modals/deploy_wallet_flow/deploy_wallet_flow.dart';
import '../modals/receive_modal.dart';
import '../modals/send_transaction_flow/send_transaction_flow.dart';
import 'wallet_button.dart';

class ProfileActions extends StatefulWidget {
  final String address;

  const ProfileActions({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  _ProfileActionsState createState() => _ProfileActionsState();
}

class _ProfileActionsState extends State<ProfileActions> {
  final tonWalletInfoBloc = getIt.get<TonWalletInfoBloc>();
  final accountInfoBloc = getIt.get<AccountInfoBloc>();

  @override
  void initState() {
    super.initState();
    tonWalletInfoBloc.add(TonWalletInfoEvent.load(widget.address));
    accountInfoBloc.add(AccountInfoEvent.load(widget.address));
  }

  @override
  void didUpdateWidget(covariant ProfileActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    tonWalletInfoBloc.add(TonWalletInfoEvent.load(widget.address));
    accountInfoBloc.add(AccountInfoEvent.load(widget.address));
  }

  @override
  void dispose() {
    tonWalletInfoBloc.close();
    accountInfoBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          WalletButton(
            onTap: () async {
              await showCrystalBottomSheet(
                context,
                padding: EdgeInsets.zero,
                draggable: false,
                wrapIntoAnimatedSize: false,
                expand: true,
                avoidBottomInsets: false,
                body: AddAssetModal(
                  address: widget.address,
                ),
              );
            },
            title: LocaleKeys.wallet_screen_actions_add_asset.tr(),
            iconAsset: Assets.images.iconAdd.path,
          ),
          BlocBuilder<AccountInfoBloc, AccountInfoState?>(
            bloc: accountInfoBloc,
            builder: (context, state) => WalletButton(
              onTap: state != null
                  ? () => showCrystalBottomSheet(
                        context,
                        title: state.account.name.capitalize,
                        body: ReceiveModalBody(
                          address: state.account.address,
                        ),
                      )
                  : null,
              title: LocaleKeys.actions_receive.tr(),
              iconAsset: Assets.images.iconReceive.path,
            ),
          ),
          BlocBuilder<TonWalletInfoBloc, TonWalletInfoState?>(
            bloc: tonWalletInfoBloc,
            builder: (context, state) => state != null
                ? !state.details.requiresSeparateDeploy || state.contractState.isDeployed
                    ? WalletButton(
                        onTap: () => SendTransactionFlow.start(
                          context: context,
                          address: state.address,
                          publicKey: state.publicKey,
                        ),
                        title: LocaleKeys.actions_send.tr(),
                        iconAsset: Assets.images.iconSend.path,
                      )
                    : WalletButton(
                        onTap: () {
                          DeployWalletFlow.start(
                            context: context,
                            address: state.address,
                            publicKey: state.publicKey,
                          );
                        },
                        title: LocaleKeys.actions_deploy.tr(),
                        iconAsset: Assets.images.iconDeploy.path,
                      )
                : const SizedBox.square(dimension: 56),
          ),
        ],
      );
}
