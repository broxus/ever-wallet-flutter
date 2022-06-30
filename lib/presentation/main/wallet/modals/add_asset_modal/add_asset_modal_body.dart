import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../data/models/token_contract_asset.dart';
import '../../../../../../data/repositories/accounts_repository.dart';
import '../../../../../../injection.dart';
import '../../../../../data/extensions.dart';
import '../../../../common/theme.dart';
import '../../../../common/widgets/crystal_flushbar.dart';
import '../../../../common/widgets/keep_alive.dart';
import '../../../../common/widgets/modal_header.dart';
import 'assets_layout.dart';
import 'custom_token_layout.dart';

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

  Future<void> onAssetsLayoutSave(List<TokenContractAsset> added, List<TokenContractAsset> removed) async {
    for (final asset in added) {
      try {
        await getIt.get<AccountsRepository>().addTokenWallet(
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
        await getIt.get<AccountsRepository>().removeTokenWallet(
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
      await getIt.get<AccountsRepository>().addTokenWallet(
            address: widget.address,
            rootTokenContract: address,
          );
    } catch (err) {
      if (!mounted) return;

      showErrorFlushbar(context, message: AppLocalizations.of(context)!.invalid_root_token_contract);
    }
  }
}
