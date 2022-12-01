import 'dart:io';

import 'package:ever_wallet/application/bloc/account/current_account_cubit.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/main/wallet/history/all_assets_layout.dart';
import 'package:ever_wallet/application/main/wallet/history/ton_wallet_transactions_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class WalletModalBody extends StatefulWidget {
  final ScrollController scrollController;
  final void Function(int)? onTabSelected;

  const WalletModalBody({
    super.key,
    required this.scrollController,
    this.onTabSelected,
  });

  @override
  _WalletModalBodyState createState() => _WalletModalBodyState();
}

class _WalletModalBodyState extends State<WalletModalBody> {
  @override
  Widget build(BuildContext context) {
    final tabs = [
      AppLocalizations.of(context)!.assets,
      AppLocalizations.of(context)!.transactions,
    ].map((e) => Text(e)).toList();

    return Material(
      color: Colors.white,
      child: Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(top: Platform.isIOS ? 19 : 6),
        child: DefaultTabController(
          length: tabs.length,
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
                      tabs: tabs,
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
                child: BlocBuilder<CurrentAccountCubit, AssetsList?>(
                  bloc: context.watch<CurrentAccountCubit>(),
                  builder: (context, state) {
                    final currentAccount = state;

                    if (currentAccount != null) {
                      return TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          AllAssetsLayout(
                            key: ValueKey('AllAssetsLayout-${currentAccount.address}'),
                            address: currentAccount.address,
                            controller: widget.scrollController,
                          ),
                          TonWalletTransactionsLayout(
                            key: ValueKey('TonWalletTransactionsLayout-${currentAccount.address}'),
                            address: currentAccount.address,
                            controller: widget.scrollController,
                          ),
                        ],
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
