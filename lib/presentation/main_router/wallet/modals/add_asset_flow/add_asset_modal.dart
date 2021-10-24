import 'dart:async';

import 'package:crystal/domain/blocs/account/account_assets_addition_bloc.dart';
import 'package:crystal/domain/blocs/account/account_assets_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/models/token_contract_asset.dart';
import '../../../../../injection.dart';
import '../../../../design/design.dart';
import 'assets_layout.dart';
import 'new_asset_layout.dart';

class AddAssetModal extends StatefulWidget {
  final String address;

  const AddAssetModal({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  _AddAssetModalState createState() => _AddAssetModalState();
}

class _AddAssetModalState extends State<AddAssetModal> with TickerProviderStateMixin {
  final accountAssetsBloc = getIt.get<AccountAssetsBloc>();
  final accountAssetsAdditionBloc = getIt.get<AccountAssetsAdditionBloc>();
  final assets = ValueNotifier<Set<String>>({});
  final newAssetLayoutScrollController = ScrollController();
  final selectAssetsLayoutScrollController = ScrollController();
  late final tabController = TabController(length: 2, vsync: this);
  late final StreamSubscription accountAssetsErrorsSubscription;
  late final StreamSubscription accountAssetsAdditionErrorsSubscription;

  @override
  void initState() {
    super.initState();
    accountAssetsErrorsSubscription =
        accountAssetsBloc.errorsStream.listen((event) => showErrorCrystalFlushbar(context, message: event));
    accountAssetsAdditionErrorsSubscription =
        accountAssetsAdditionBloc.errorsStream.listen((event) => showErrorCrystalFlushbar(context, message: event));
    accountAssetsBloc.add(AccountAssetsEvent.load(widget.address));
  }

  @override
  void didUpdateWidget(covariant AddAssetModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    accountAssetsBloc.add(AccountAssetsEvent.load(widget.address));
  }

  @override
  void dispose() {
    accountAssetsBloc.close();
    accountAssetsAdditionBloc.close();
    selectAssetsLayoutScrollController.dispose();
    newAssetLayoutScrollController.dispose();
    assets.dispose();
    accountAssetsErrorsSubscription.cancel();
    accountAssetsAdditionErrorsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          if (FocusScope.of(context).hasFocus) {
            FocusScope.of(context).unfocus();
          }
          return true;
        },
        child: SafeArea(
          minimum: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _modalTitle(),
              const CrystalDivider(height: 8),
              _tabRow(),
              Flexible(child: _layout()),
            ],
          ),
        ),
      );

  Widget _modalTitle() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          LocaleKeys.add_assets_modal_title.tr(),
          style: const TextStyle(
            fontSize: 24,
            color: CrystalColor.fontDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  Widget _tabRow() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
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
        ),
      );

  Widget _layout() => LayoutBuilder(
        builder: (context, constraints) => BlocBuilder<AccountAssetsBloc, AccountAssetsState>(
          bloc: accountAssetsBloc,
          builder: (context, state) => TabBarView(
            controller: tabController,
            children: [
              AssetsLayout(
                controller: selectAssetsLayoutScrollController,
                added: state.added,
                available: state.available,
                onSave: (List<TokenContractAsset> assets) {
                  for (final asset in assets) {
                    accountAssetsAdditionBloc.add(AccountAssetsAdditionEvent.add(
                      address: widget.address,
                      rootTokenContract: asset.address,
                    ));
                  }
                },
              ),
              NewAssetLayout(
                controller: newAssetLayoutScrollController,
                onSave: (String address) => accountAssetsAdditionBloc.add(AccountAssetsAdditionEvent.add(
                  address: widget.address,
                  rootTokenContract: address,
                )),
              ),
            ]
                .map(
                  (e) => Padding(
                    padding: context.keyboardInsets,
                    child: KeepAliveWidget(child: e),
                  ),
                )
                .toList(),
          ),
        ),
      );
}
