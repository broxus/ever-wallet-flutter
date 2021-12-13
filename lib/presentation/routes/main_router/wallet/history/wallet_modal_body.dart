import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../domain/blocs/account/accounts_bloc.dart';
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
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      LocaleKeys.wallet_history_modal_tabs_assets,
      LocaleKeys.wallet_history_modal_tabs_transactions,
    ].map((e) => Text(e.tr())).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        child: Container(
          height: context.screenSize.height,
          padding: EdgeInsets.only(top: Platform.isIOS ? 19 : 6),
          child: DefaultTabController(
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
                  child: BlocBuilder<AccountsBloc, AccountsState>(
                    bloc: context.watch<AccountsBloc>(),
                    builder: (context, state) => TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        if (state.currentAccount != null)
                          AllAssetsLayout(
                            address: state.currentAccount!.address,
                            controller: widget.scrollController,
                          )
                        else
                          const SizedBox(),
                        if (state.currentAccount != null)
                          TonWalletTransactionsLayout(
                            address: state.currentAccount!.address,
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
          ),
        ),
      );
}
