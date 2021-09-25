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
  late final AssetsBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = getIt.get<AssetsBloc>(param1: widget.address);
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<AssetsBloc, AssetsState>(
        bloc: bloc,
        builder: (context, state) => state.maybeWhen(
          ready: (tonWallet, tokenWallets) => AnimatedSwitcher(
            duration: kThemeAnimationDuration,
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: context.safeArea.bottom + 12,
              ),
              controller: widget.controller,
              children: [
                TonWalletAssetHolder(
                  key: ValueKey(tonWallet.address),
                  address: tonWallet.address,
                ),
                ...tokenWallets
                    .map((tokenWallet) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              height: 1,
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              color: CrystalColor.divider,
                            ),
                            TokenWalletAssetHolder(
                              key: ValueKey('${tokenWallet.item1.owner}_${tokenWallet.item1.symbol.rootTokenContract}'),
                              owner: tokenWallet.item1.owner,
                              rootTokenContract: tokenWallet.item1.symbol.rootTokenContract,
                            ),
                          ],
                        ))
                    .toList(),
              ],
            ),
          ),
          orElse: () => const SizedBox(),
        ),
      );
}
