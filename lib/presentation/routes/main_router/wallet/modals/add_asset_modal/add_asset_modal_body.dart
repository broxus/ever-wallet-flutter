import 'package:flutter/material.dart';

import '../../../../../../data/dtos/token_contract_asset_dto.dart';
import '../../../../../../data/repositories/accounts_repository.dart';
import '../../../../../../injection.dart';
import '../../../../../design/design.dart';
import '../../../../../design/widgets/crystal_flushbar.dart';
import '../../../../../design/widgets/keep_alive.dart';
import '../../../../../design/widgets/modal_header.dart';
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ModalHeader(
                  text: LocaleKeys.add_assets_modal_title.tr(),
                ),
                const SizedBox(height: 16),
                tabs(),
                const SizedBox(height: 16),
                Expanded(
                  child: layout(),
                ),
              ],
            ),
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
              Text(LocaleKeys.add_assets_modal_search_layout_tab.tr()),
              Text(LocaleKeys.add_assets_modal_create_layout_tab.tr()),
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

  Future<void> onAssetsLayoutSave(List<TokenContractAssetDto> added, List<TokenContractAssetDto> removed) async {
    for (final asset in added) {
      try {
        await getIt.get<AccountsRepository>().addTokenWallet(
              address: widget.address,
              rootTokenContract: asset.address,
            );
      } catch (err) {
        if (!mounted) return;

        showErrorCrystalFlushbar(
          context,
          message: err.toString(),
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

        showErrorCrystalFlushbar(
          context,
          message: err.toString(),
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

      showErrorCrystalFlushbar(context, message: 'Invalid root token contract');
    }
  }
}
