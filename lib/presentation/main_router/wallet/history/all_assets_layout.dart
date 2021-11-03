import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/blocs/account/account_assets_bloc.dart';
import '../../../../injection.dart';
import '../../../design/design.dart';
import 'token_wallet_asset_holder.dart';
import 'ton_wallet_asset_holder.dart';

class AllAssetsLayout extends StatefulWidget {
  final String address;
  final ScrollController controller;
  final Widget Function(String) placeholderBuilder;

  const AllAssetsLayout({
    Key? key,
    required this.address,
    required this.controller,
    required this.placeholderBuilder,
  }) : super(key: key);

  @override
  _AllAssetsLayoutState createState() => _AllAssetsLayoutState();
}

class _AllAssetsLayoutState extends State<AllAssetsLayout> {
  final bloc = getIt.get<AccountAssetsBloc>();

  @override
  void initState() {
    super.initState();
    bloc.add(AccountAssetsEvent.load(widget.address));
  }

  @override
  void didUpdateWidget(covariant AllAssetsLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.address != widget.address) {
      bloc.add(AccountAssetsEvent.load(widget.address));
    }
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<AccountAssetsBloc, AccountAssetsState>(
        bloc: bloc,
        builder: (context, state) {
          final list = [
            if (state.tonWalletAsset != null)
              TonWalletAssetHolder(
                key: ValueKey(state.tonWalletAsset),
                address: state.tonWalletAsset!.address,
              ),
            if (state.tonWalletAsset != null)
              ...state.tokenContractAssets
                  .map((tokenContractAsset) => TokenWalletAssetHolder(
                        key: ValueKey(tokenContractAsset),
                        owner: state.tonWalletAsset!.address,
                        rootTokenContract: tokenContractAsset.address,
                        svgIcon: tokenContractAsset.svgIcon,
                        gravatarIcon: tokenContractAsset.gravatarIcon,
                      ))
                  .toList(),
          ];

          return AnimatedSwitcher(
            duration: kThemeAnimationDuration,
            child: ListView.separated(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              controller: widget.controller,
              itemCount: list.length,
              separatorBuilder: (_, __) => Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: CrystalColor.divider,
              ),
              itemBuilder: (context, index) => list[index],
            ),
          );
        },
      );
}
