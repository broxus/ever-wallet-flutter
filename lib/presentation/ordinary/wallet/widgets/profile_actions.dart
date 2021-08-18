import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

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
  final SubscriptionSubject subscriptionSubject;

  const ProfileActions({
    Key? key,
    required this.subscriptionSubject,
  }) : super(key: key);

  @override
  _ProfileActionsState createState() => _ProfileActionsState();
}

class _ProfileActionsState extends State<ProfileActions> {
  late final TonWalletInfoBloc tonWalletInfoBloc;
  late final AccountInfoBloc accountInfoBloc;

  @override
  void initState() {
    super.initState();
    tonWalletInfoBloc = getIt.get<TonWalletInfoBloc>(param1: widget.subscriptionSubject.value.tonWallet);
    accountInfoBloc = getIt.get<AccountInfoBloc>(param1: widget.subscriptionSubject.value.accountSubject);
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
              await CrystalBottomSheet.show(
                context,
                padding: EdgeInsets.zero,
                draggable: false,
                wrapIntoAnimatedSize: false,
                expand: true,
                avoidBottomInsets: false,
                body: AddAssetModal(
                  subscriptionSubject: widget.subscriptionSubject,
                ),
              );
            },
            title: LocaleKeys.wallet_screen_actions_add_asset.tr(),
            iconAsset: Assets.images.iconAdd.path,
          ),
          BlocBuilder<AccountInfoBloc, AccountInfoState>(
            bloc: accountInfoBloc,
            builder: (context, state) => state.maybeWhen(
              ready: (name) => BlocBuilder<TonWalletInfoBloc, TonWalletInfoState>(
                bloc: tonWalletInfoBloc,
                builder: (context, state) => state.maybeWhen(
                  ready: (address, contractState, walletType, details, publicKey) => WalletButton(
                    onTap: () {
                      CrystalBottomSheet.show(
                        context,
                        title: name.capitalize,
                        body: ReceiveModalBody(
                          address: address,
                        ),
                      );
                    },
                    title: LocaleKeys.actions_receive.tr(),
                    iconAsset: Assets.images.iconReceive.path,
                  ),
                  orElse: () => WalletButton(
                    title: LocaleKeys.actions_receive.tr(),
                    iconAsset: Assets.images.iconReceive.path,
                  ),
                ),
              ),
              orElse: () => WalletButton(
                title: LocaleKeys.actions_receive.tr(),
                iconAsset: Assets.images.iconReceive.path,
              ),
            ),
          ),
          BlocBuilder<TonWalletInfoBloc, TonWalletInfoState>(
            bloc: tonWalletInfoBloc,
            builder: (context, state) => state.maybeWhen(
              ready: (address, contractState, walletType, details, publicKey) =>
                  !details.requiresSeparateDeploy || contractState.isDeployed
                      ? WalletButton(
                          onTap: () => SendTransactionFlow.start(
                            context: context,
                            tonWallet: widget.subscriptionSubject.value.tonWallet,
                          ),
                          title: LocaleKeys.actions_send.tr(),
                          iconAsset: Assets.images.iconSend.path,
                        )
                      : WalletButton(
                          onTap: () {
                            DeployWalletFlow.start(
                              context: context,
                              tonWallet: widget.subscriptionSubject.value.tonWallet,
                            );
                          },
                          title: LocaleKeys.actions_deploy.tr(),
                          iconAsset: Assets.images.iconDeploy.path,
                        ),
              orElse: () => WalletButton(
                title: LocaleKeys.actions_deploy.tr(),
                iconAsset: Assets.images.iconDeploy.path,
              ),
            ),
          ),
        ],
      );
}
