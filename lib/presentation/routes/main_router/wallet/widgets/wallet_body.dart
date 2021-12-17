import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../domain/blocs/account/accounts_bloc.dart';
import '../../../../../domain/blocs/account/current_account_bloc.dart';
import '../../../../../domain/models/account.dart';
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
          child: BlocBuilder<CurrentAccountBloc, Account?>(
            builder: (context, currentAccountState) => BlocBuilder<AccountsBloc, List<Account>>(
              bloc: context.watch<AccountsBloc>(),
              builder: (context, accountsState) => Column(
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
                      accounts: accountsState,
                      onPageChanged: (i) {
                        if (i < accountsState.length) {
                          context.read<CurrentAccountBloc>().add(
                                CurrentAccountEvent.setCurrent(
                                  address: accountsState[i].when(
                                    internal: (assetsList) => assetsList.address,
                                    external: (assetsList) => assetsList.address,
                                  ),
                                  isExternal: accountsState[i].when(
                                    internal: (_) => false,
                                    external: (_) => true,
                                  ),
                                ),
                              );
                        } else {
                          modalController.hide();
                          context.read<CurrentAccountBloc>().add(
                                const CurrentAccountEvent.setCurrent(),
                              );
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
                  const CrystalDivider(height: 16),
                  if (currentAccountState != null)
                    ProfileActions(
                      address: currentAccountState.when(
                        internal: (assetsList) => assetsList.address,
                        external: (assetsList) => assetsList.address,
                      ),
                      isExternal: currentAccountState.when(
                        internal: (_) => false,
                        external: (_) => true,
                      ),
                    ),
                  const CrystalDivider(height: 20),
                ],
              ),
            ),
          ),
        ),
      );
}
