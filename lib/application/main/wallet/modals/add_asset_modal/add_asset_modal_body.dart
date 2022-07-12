import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/crystal_flushbar.dart';
import 'package:ever_wallet/application/common/widgets/keep_alive.dart';
import 'package:ever_wallet/application/common/widgets/modal_header.dart';
import 'package:ever_wallet/application/main/wallet/modals/add_asset_modal/assets_layout.dart';
import 'package:ever_wallet/application/main/wallet/modals/add_asset_modal/custom_token_layout.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/models/token_contract_asset.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddAssetModalBody extends StatefulWidget {
  final String address;

  const AddAssetModalBody({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  State<AddAssetModalBody> createState() => _AddAssetModalBodyState();
}

class _AddAssetModalBodyState extends State<AddAssetModalBody> with TickerProviderStateMixin {
  late final tabController = TabController(
    length: 2,
    vsync: this,
  );

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: ModalHeader(
                  text: AppLocalizations.of(context)!.select_new_assets,
                ),
              ),
              tabs(),
              Expanded(
                child: layout(),
              ),
            ],
          ),
        ),
      );

  Widget tabs() => Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              color: CrystalColor.divider,
            ),
          ),
          TabBar(
            controller: tabController,
            tabs: [
              Text(AppLocalizations.of(context)!.search),
              Text(AppLocalizations.of(context)!.custom_token),
            ],
            labelStyle: const TextStyle(fontSize: 16, letterSpacing: 0.25),
            unselectedLabelColor: CrystalColor.fontSecondaryDark,
            labelColor: CrystalColor.accent,
            labelPadding: const EdgeInsets.symmetric(vertical: 10),
            indicatorColor: CrystalColor.accent,
            onTap: (i) {
              FocusScope.of(context).unfocus();
            },
          ),
        ],
      );

  Widget layout() => TabBarView(
        controller: tabController,
        children: [
          KeepAliveWidget(
            child: AssetsLayout(
              address: widget.address,
              onSave: onAssetsLayoutSave,
            ),
          ),
          KeepAliveWidget(
            child: CustomTokenLayout(
              onSave: onCustomTokenLayoutSave,
            ),
          ),
        ],
      );

  Future<void> onAssetsLayoutSave(
    List<TokenContractAsset> added,
    List<TokenContractAsset> removed,
  ) async {
    for (final asset in added) {
      try {
        await context.read<AccountsRepository>().addTokenWallet(
              address: widget.address,
              rootTokenContract: asset.address,
            );
      } catch (err) {
        if (!mounted) return;

        showErrorFlushbar(
          context,
          message: (err as Exception).toUiMessage(),
        );
      }
    }

    for (final asset in removed) {
      try {
        if (!mounted) return;

        await context.read<AccountsRepository>().removeTokenWallet(
              address: widget.address,
              rootTokenContract: asset.address,
            );
      } catch (err) {
        if (!mounted) return;

        showErrorFlushbar(
          context,
          message: (err as Exception).toUiMessage(),
        );
      }
    }
  }

  Future<void> onCustomTokenLayoutSave(String address) async {
    try {
      await context.read<AccountsRepository>().addTokenWallet(
            address: widget.address,
            rootTokenContract: address,
          );
    } catch (err) {
      if (!mounted) return;

      showErrorFlushbar(context, message: context.localization.invalid_root_token_contract);
    }
  }
}
