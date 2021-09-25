import 'package:flutter/material.dart';

import '../../../design/design.dart';
import 'all_assets_layout.dart';
import 'transactions_layout.dart';

class WalletModalBody extends StatefulWidget {
  final String address;
  final ScrollController scrollController;
  final void Function(int)? onTabSelected;

  const WalletModalBody({
    Key? key,
    required this.address,
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
  Widget build(BuildContext context) => AnimatedAppearance(
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
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      AllAssetsLayout(
                        address: widget.address,
                        controller: widget.scrollController,
                        placeholderBuilder: buildPlaceholder,
                      ),
                      TransactionsLayout(
                        address: widget.address,
                        controller: widget.scrollController,
                        placeholderBuilder: buildPlaceholder,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );

  Widget buildPlaceholder(String text) => Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: CrystalColor.fontSecondaryDark,
            ),
          ),
        ),
      );
}
