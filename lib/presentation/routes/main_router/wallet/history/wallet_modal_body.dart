import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../domain/blocs/account/current_account_bloc.dart';
import '../../../../design/design.dart';
import 'all_assets_layout.dart';
import 'ton_wallet_transactions_layout.dart';

class WalletModalBody extends StatefulWidget {
  final ScrollController scrollController;
  final void Function(int)? onTabSelected;

  const WalletModalBody({
    Key? key,
    required this.scrollController,
    this.onTabSelected,
  }) : super(key: key);

  @override
  _WalletModalBodyState createState() => _WalletModalBodyState();
}

class _WalletModalBodyState extends State<WalletModalBody> {
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        child: Container(
          height: context.screenSize.height,
          padding: EdgeInsets.only(top: Platform.isIOS ? 19 : 6),
          child: BlocBuilder<CurrentAccountBloc, AssetsList?>(
            bloc: context.watch<CurrentAccountBloc>(),
            builder: (context, currentAccountState) {
              final _tabs = [
                LocaleKeys.wallet_history_modal_tabs_assets,
                LocaleKeys.wallet_history_modal_tabs_transactions,
              ].map((e) => Text(e.tr())).toList();

              return DefaultTabController(
                length: _tabs.length,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
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
                            tabs: _tabs,
                            labelStyle: const TextStyle(fontSize: 16),
                            labelColor: CrystalColor.accent,
                            unselectedLabelColor: CrystalColor.fontSecondaryDark,
                            labelPadding: const EdgeInsets.symmetric(vertical: 10),
                            onTap: widget.onTabSelected,
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: BlocBuilder<CurrentAccountBloc, AssetsList?>(
                        bloc: context.watch<CurrentAccountBloc>(),
                        builder: (context, currentAccountState) => TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            if (currentAccountState != null)
                              AllAssetsLayout(
                                address: currentAccountState.address,
                                controller: widget.scrollController,
                              )
                            else
                              const SizedBox(),
                            if (currentAccountState != null)
                              TonWalletTransactionsLayout(
                                address: currentAccountState.address,
                                controller: widget.scrollController,
                              )
                            else
                              const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
}
