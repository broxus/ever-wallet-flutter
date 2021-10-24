import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../domain/blocs/account/accounts_bloc.dart';
import '../../../design/design.dart';
import 'profile_actions.dart';
import 'profile_carousel.dart';

class WalletBody extends StatelessWidget {
  final List<AssetsList> accounts;
  final AssetsList? currentAccount;
  final PanelController modalController;

  const WalletBody({
    Key? key,
    required this.accounts,
    required this.currentAccount,
    required this.modalController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => AnimatedAppearance(
        duration: const Duration(milliseconds: 400),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        LocaleKeys.wallet_screen_title.tr(),
                        style: const TextStyle(
                          fontSize: 30,
                          letterSpacing: 0.25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const CrystalDivider(height: 16),
                AnimatedAppearance(
                  duration: const Duration(milliseconds: 250),
                  offset: const Offset(1, 0),
                  child: ProfileCarousel(
                    accounts: accounts,
                    onPageChanged: (i) {
                      if (i < accounts.length) {
                        context.read<AccountsBloc>().add(AccountsEvent.setCurrent(accounts[i].address));
                      } else {
                        modalController.hide();
                        context.read<AccountsBloc>().add(const AccountsEvent.setCurrent(null));
                      }
                    },
                    onPageSelected: (i) {
                      if (i == accounts.length) {
                        modalController.hide();
                      } else {
                        modalController.show();
                      }
                    },
                  ),
                ),
                const CrystalDivider(height: 16),
                if (currentAccount != null) ProfileActions(address: currentAccount!.address),
                const CrystalDivider(height: 20),
              ],
            ),
          ),
        ),
      );
}
