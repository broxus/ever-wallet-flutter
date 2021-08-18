import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../domain/blocs/subscription/assets_bloc.dart';
import '../../../../injection.dart';
import '../../../design/design.dart';
import 'token_wallet_asset_holder.dart';
import 'ton_wallet_asset_holder.dart';

class AllAssetsLayout extends StatefulWidget {
  final SubscriptionSubject subscriptionSubject;
  final ScrollController controller;
  final Widget Function(String) placeholderBuilder;

  const AllAssetsLayout({
    Key? key,
    required this.subscriptionSubject,
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
    bloc = getIt.get<AssetsBloc>(param1: widget.subscriptionSubject);
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
                bottom: context.safeArea.bottom + 12.0,
              ),
              controller: widget.controller,
              children: [
                TonWalletAssetHolder(
                  key: ValueKey(tonWallet),
                  tonWallet: tonWallet,
                ),
                ...tokenWallets
                    .map((tokenWallet) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              height: 1,
                              margin: const EdgeInsets.symmetric(horizontal: 16.0),
                              color: CrystalColor.divider,
                            ),
                            TokenWalletAssetHolder(
                              key: ValueKey(tokenWallet.item1),
                              tokenWallet: tokenWallet.item1,
                              logoURI: tokenWallet.item2,
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
