import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/blocs/subscriptions/assets_bloc.dart';
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
  final bloc = getIt.get<AssetsBloc>();

  @override
  void initState() {
    super.initState();
    bloc.add(AssetsEvent.load(widget.address));
  }

  @override
  void didUpdateWidget(covariant AllAssetsLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    bloc.add(AssetsEvent.load(widget.address));
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<AssetsBloc, AssetsState>(
        bloc: bloc,
        builder: (context, state) => AnimatedSwitcher(
          duration: kThemeAnimationDuration,
          child: ListView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: context.safeArea.bottom + 12,
            ),
            controller: widget.controller,
            children: [
              if (state.tonWallet != null)
                TonWalletAssetHolder(
                  address: state.tonWallet!.address,
                ),
              ...state.tokenWallets
                  .map(
                    (tokenWallet) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          color: CrystalColor.divider,
                        ),
                        TokenWalletAssetHolder(
                          owner: tokenWallet.item1.owner,
                          rootTokenContract: tokenWallet.item1.symbol.rootTokenContract,
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
      );
}
