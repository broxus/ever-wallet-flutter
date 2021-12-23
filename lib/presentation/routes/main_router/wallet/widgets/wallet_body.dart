import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../domain/blocs/account/accounts_bloc.dart';
import '../../../../../domain/blocs/account/current_account_bloc.dart';
import '../../../../design/design.dart';
import '../../../../design/widgets/animated_appearance.dart';
import '../../../../design/widgets/sliding_panel.dart';
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
          child: Column(
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
              const SizedBox(height: 16),
              AnimatedAppearance(
                duration: const Duration(milliseconds: 250),
                offset: const Offset(1, 0),
                child: BlocBuilder<AccountsBloc, List<AssetsList>>(
                  bloc: context.watch<AccountsBloc>(),
                  builder: (context, accountsState) => ProfileCarousel(
                    accounts: accountsState,
                    onPageChanged: (i) {
                      if (i < accountsState.length) {
                        context
                            .read<CurrentAccountBloc>()
                            .add(CurrentAccountEvent.setCurrent(accountsState[i].address));
                      } else {
                        modalController.hide();
                        context.read<CurrentAccountBloc>().add(const CurrentAccountEvent.setCurrent());
                      }
                    },
                    onPageSelected: (i) {
                      if (i == accountsState.length) {
                        modalController.hide();
                      } else {
                        modalController.show();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<CurrentAccountBloc, AssetsList?>(
                bloc: context.watch<CurrentAccountBloc>(),
                builder: (context, currentAccountState) => currentAccountState != null
                    ? ProfileActions(address: currentAccountState.address)
                    : const SizedBox(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
}
