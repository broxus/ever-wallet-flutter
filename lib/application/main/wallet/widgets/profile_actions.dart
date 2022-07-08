import 'package:collection/collection.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/main/wallet/modals/add_asset_modal/show_add_asset_modal.dart';
import 'package:ever_wallet/application/main/wallet/modals/deploy_wallet_flow/start_deploy_wallet_flow.dart';
import 'package:ever_wallet/application/main/wallet/modals/receive_modal/show_receive_modal.dart';
import 'package:ever_wallet/application/main/wallet/modals/send_transaction_flow/start_send_transaction_flow.dart';
import 'package:ever_wallet/application/main/wallet/widgets/wallet_button.dart';
import 'package:ever_wallet/data/models/ton_wallet_info.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:provider/provider.dart';

class ProfileActions extends StatelessWidget {
  final String address;

  const ProfileActions({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          WalletButton(
            onTap: () async => showAddAssetModal(
              context: context,
              address: address,
            ),
            title: AppLocalizations.of(context)!.add_asset,
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
          StreamProvider<AsyncValue<AssetsList>>(
            create: (context) => context
                .read<AccountsRepository>()
                .accountInfo(address)
                .map((event) => AsyncValue.ready(event)),
            initialData: const AsyncValue.loading(),
            catchError: (context, error) => AsyncValue.error(error),
            builder: (context, child) {
              final value = context.watch<AsyncValue<AssetsList>>().maybeWhen(
                    ready: (value) => value,
                    orElse: () => null,
                  );

              return WalletButton(
                onTap: value != null
                    ? () => showReceiveModal(
                          context: context,
                          address: value.address,
                        )
                    : null,
                title: AppLocalizations.of(context)!.receive,
                icon: Assets.images.iconReceive.svg(
                  color: CrystalColor.secondary,
                ),
              );
            },
          ),
          StreamProvider<AsyncValue<Map<KeyStoreEntry, List<KeyStoreEntry>?>>>(
            create: (context) => context
                .read<KeysRepository>()
                .mappedKeysStream
                .map((event) => AsyncValue.ready(event)),
            initialData: const AsyncValue.loading(),
            catchError: (context, error) => AsyncValue.error(error),
            builder: (context, child) {
              final keys =
                  context.watch<AsyncValue<Map<KeyStoreEntry, List<KeyStoreEntry>?>>>().maybeWhen(
                        ready: (value) => value,
                        orElse: () => <KeyStoreEntry, List<KeyStoreEntry>?>{},
                      );

              return StreamProvider<AsyncValue<KeyStoreEntry?>>(
                create: (context) => context
                    .read<KeysRepository>()
                    .currentKeyStream
                    .map((event) => AsyncValue.ready(event)),
                initialData: const AsyncValue.loading(),
                catchError: (context, error) => AsyncValue.error(error),
                builder: (context, child) {
                  final currentKey = context.watch<AsyncValue<KeyStoreEntry?>>().maybeWhen(
                        ready: (value) => value,
                        orElse: () => null,
                      );

                  return StreamProvider<AsyncValue<TonWalletInfo?>>(
                    create: (context) => context
                        .read<TonWalletsRepository>()
                        .getInfoStream(address)
                        .map((event) => AsyncValue.ready(event)),
                    initialData: const AsyncValue.loading(),
                    catchError: (context, error) => AsyncValue.error(error),
                    builder: (context, child) {
                      final tonWalletInfo = context.watch<AsyncValue<TonWalletInfo?>>().maybeWhen(
                            ready: (value) => value,
                            orElse: () => null,
                          );

                      if (currentKey != null && tonWalletInfo != null) {
                        final requiresSeparateDeploy = tonWalletInfo.details.requiresSeparateDeploy;

                        if (!requiresSeparateDeploy) {
                          return WalletButton(
                            onTap: () => startSendTransactionFlow(
                              context: context,
                              address: address,
                              publicKeys: [tonWalletInfo.publicKey],
                            ),
                            title: AppLocalizations.of(context)!.send,
                            icon: Assets.images.iconSend.svg(
                              color: CrystalColor.secondary,
                            ),
                          );
                        }

                        final isDeployed = tonWalletInfo.contractState.isDeployed;

                        if (isDeployed) {
                          final keysList = [
                            ...keys.keys,
                            ...keys.values.whereNotNull().expand((e) => e),
                          ];

                          final custodians = tonWalletInfo.custodians ?? [];

                          final localCustodians = keysList
                              .where((e) => custodians.any((el) => el == e.publicKey))
                              .toList();

                          final initiatorKey = localCustodians
                              .firstWhereOrNull((e) => e.publicKey == currentKey.publicKey);

                          final listOfKeys = [
                            if (initiatorKey != null) initiatorKey,
                            ...localCustodians.where((e) => e.publicKey != initiatorKey?.publicKey),
                          ];

                          final publicKeys = listOfKeys.map((e) => e.publicKey).toList();

                          return WalletButton(
                            onTap: publicKeys.isNotEmpty
                                ? () => startSendTransactionFlow(
                                      context: context,
                                      address: address,
                                      publicKeys: publicKeys,
                                    )
                                : null,
                            title: AppLocalizations.of(context)!.send,
                            icon: Assets.images.iconSend.svg(
                              color: CrystalColor.secondary,
                            ),
                          );
                        } else {
                          return WalletButton(
                            onTap: () => startDeployWalletFlow(
                              context: context,
                              address: address,
                              publicKey: tonWalletInfo.publicKey,
                            ),
                            title: AppLocalizations.of(context)!.deploy,
                            icon: Assets.images.iconDeploy.svg(
                              color: CrystalColor.secondary,
                            ),
                          );
                        }
                      } else {
                        return WalletButton(
                          title: AppLocalizations.of(context)!.send,
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
          ),
        ],
      );
}
