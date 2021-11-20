import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../domain/blocs/account/accounts_bloc.dart';
import '../../../../design/design.dart';
import 'connection_button.dart';
import 'profile_actions.dart';
import 'profile_carousel.dart';

class WalletBody extends StatelessWidget {
  final PanelController modalController;

  const WalletBody({
    Key? key,
    required this.modalController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 14),
          child: BlocBuilder<AccountsBloc, AccountsState>(
            bloc: context.watch<AccountsBloc>(),
            builder: (context, state) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LocaleKeys.wallet_screen_title.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          letterSpacing: 0.25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const ConnectionButton(),
                    ],
                  ),
                ),
                const CrystalDivider(height: 16),
                AnimatedAppearance(
                  duration: const Duration(milliseconds: 250),
                  offset: const Offset(1, 0),
                  child: ProfileCarousel(
                    accounts: state.accounts,
                    onPageChanged: (i) {
                      if (i < state.accounts.length) {
                        context.read<AccountsBloc>().add(AccountsEvent.setCurrent(state.accounts[i].address));
                      } else {
                        modalController.hide();
                        context.read<AccountsBloc>().add(const AccountsEvent.setCurrent(null));
                      }
                    },
                    onPageSelected: (i) {
                      if (i == state.accounts.length) {
                        modalController.hide();
                      } else {
                        modalController.show();
                      }
                    },
                  ),
                ),
                const CrystalDivider(height: 16),
                if (state.currentAccount != null) ProfileActions(address: state.currentAccount!.address),
                const CrystalDivider(height: 20),
              ],
            ),
          ),
        ),
      );
}
