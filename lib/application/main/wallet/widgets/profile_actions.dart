import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/general/ew_bottom_sheet.dart';
import 'package:ever_wallet/application/common/general/flushbar.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/transport_type_builder.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/add_new_seed_sheet/add_new_seed_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/add_asset_modal/show_add_asset_modal.dart';
import 'package:ever_wallet/application/main/wallet/modals/deploy_wallet_flow/start_deploy_wallet_flow.dart';
import 'package:ever_wallet/application/main/wallet/modals/receive_modal/show_receive_modal.dart';
import 'package:ever_wallet/application/main/wallet/modals/send_transaction_flow/start_send_transaction_flow.dart';
import 'package:ever_wallet/application/main/wallet/stever/stever_screen.dart';
import 'package:ever_wallet/application/main/wallet/widgets/wallet_button.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:ever_wallet/data/models/stever/stever_withdraw_request.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/data/repositories/stever_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:provider/provider.dart';

class ProfileActions extends StatelessWidget {
  final String address;

  const ProfileActions({
    super.key,
    required this.address,
  });

  @override
  Widget build(BuildContext context) => TransportTypeBuilderWidget(
        builder: (context, isEver) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              WalletButton(
                onTap: () async => showAddAssetModal(
                  context: context,
                  address: address,
                ),
                title: context.localization.add_asset,
                icon: const OverflowBox(
                  maxHeight: 30,
                  maxWidth: 30,
                  child: Center(
                    child: Icon(
                      Icons.add,
                      size: 30,
                      color: CrystalColor.secondary,
                    ),
                  ),
                ),
              ),
              WalletButton(
                onTap: () => showReceiveModal(
                  context: context,
                  address: address,
                ),
                title: context.localization.receive,
                icon: Assets.images.iconReceive.svg(
                  color: CrystalColor.secondary,
                ),
              ),
              AsyncValueStreamProvider<List<String>?>(
                create: (context) =>
                    context.read<TonWalletsRepository>().localCustodiansStream(address),
                builder: (context, child) {
                  final localCustodians = context.watch<AsyncValue<List<String>?>>().maybeWhen(
                        ready: (value) => value,
                        orElse: () => null,
                      );

                  return AsyncValueStreamProvider<AssetsList>(
                    create: (context) => context
                        .read<AccountsRepository>()
                        .accountsStream
                        .expand((e) => e)
                        .where((e) => e.address == address),
                    builder: (context, child) {
                      final account = context.watch<AsyncValue<AssetsList>>().maybeWhen(
                            ready: (value) => value,
                            orElse: () => null,
                          );

                      return AsyncValueStreamProvider<TonWalletDetails>(
                        create: (context) =>
                            context.read<TonWalletsRepository>().detailsStream(address),
                        builder: (context, child) {
                          final details = context.watch<AsyncValue<TonWalletDetails>>().maybeWhen(
                                ready: (value) => value,
                                orElse: () => null,
                              );

                          return AsyncValueStreamProvider<ContractState>(
                            create: (context) =>
                                context.read<TonWalletsRepository>().contractStateStream(address),
                            builder: (context, child) {
                              final contractState =
                                  context.watch<AsyncValue<ContractState>>().maybeWhen(
                                        ready: (value) => value,
                                        orElse: () => null,
                                      );

                              if (account != null && details != null && contractState != null) {
                                final requiresSeparateDeploy = details.requiresSeparateDeploy;

                                if (!requiresSeparateDeploy) {
                                  return WalletButton(
                                    onTap: () => startSendTransactionFlow(
                                      context: context,
                                      address: address,
                                      publicKeys: [account.publicKey],
                                    ),
                                    title: context.localization.send,
                                    icon: Assets.images.iconSend.svg(
                                      color: CrystalColor.secondary,
                                    ),
                                  );
                                }

                                final isDeployed = contractState.isDeployed;

                                if (isDeployed) {
                                  return WalletButton(
                                    onTap: localCustodians != null && localCustodians.isNotEmpty
                                        ? () => startSendTransactionFlow(
                                              context: context,
                                              address: address,
                                              publicKeys: localCustodians,
                                            )
                                        : () => showFlushbarWithAction(
                                              context: context,
                                              text: context
                                                  .localization.add_custodians_to_send_via_multisig,
                                              actionText: context.localization.add_word,
                                              isOneLine: false,
                                              action: () => showEWBottomSheet<void>(
                                                context,
                                                body: (_) => const AddNewSeedSheet(),
                                                needCloseButton: false,
                                                avoidBottomInsets: false,
                                              ),
                                            ),
                                    title: context.localization.send,
                                    icon: Assets.images.iconSend.svg(
                                      color: CrystalColor.secondary,
                                    ),
                                  );
                                } else {
                                  return WalletButton(
                                    onTap: () => startDeployWalletFlow(
                                      context: context,
                                      address: address,
                                      publicKey: account.publicKey,
                                    ),
                                    title: context.localization.deploy,
                                    icon: Assets.images.iconDeploy.svg(
                                      color: CrystalColor.secondary,
                                    ),
                                  );
                                }
                              } else {
                                return WalletButton(
                                  title: context.localization.send,
                                  icon: Assets.images.iconSend.svg(
                                    color: CrystalColor.secondary,
                                  ),
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
              if (isEver)
                StreamBuilder<List<StEverWithdrawRequest>>(
                  stream: context.read<StEverRepository>().withdrawRequestsStream(address),
                  builder: (context, snap) {
                    final requests = snap.data ?? [];
                    final wasOpened = context.read<HiveSource>().wasStEverOpened;

                    final button = WalletButton(
                      title: context.localization.stake_word,
                      icon: Assets.images.stever.stake.svg(
                        color: CrystalColor.secondary,
                      ),
                      onTap: () => Navigator.of(context, rootNavigator: true)
                          .push(StEverScreenRoute(address)),
                    );

                    return Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        button,
                        if (!wasOpened)
                          Positioned(
                            right: -10,
                            top: -10,
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ColorsRes.bluePrimary400,
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Text(
                                context.localization.new_word,
                                style: StylesRes.medium12.copyWith(color: ColorsRes.white),
                              ),
                            ),
                          ),
                        if (requests.isNotEmpty)
                          Positioned(
                            right: 1,
                            top: 1,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: ColorsRes.caution,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
            ],
          );
        },
      );
}
