import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/blocs/account/current_accounts_bloc.dart';
import '../../../injection.dart';
import '../../design/design.dart';
import 'history/wallet_modal_body.dart';
import 'widgets/wallet_body.dart';
import 'widgets/wallet_scaffold.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final modalController = PanelController(initialState: PanelState.hidden);
  final currentAccountsBloc = getIt.get<CurrentAccountsBloc>();

  @override
  void dispose() {
    modalController.close();
    currentAccountsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: ColoredBox(
          color: CrystalColor.background,
          child: AnimatedAppearance(
            child: BlocBuilder<CurrentAccountsBloc, CurrentAccountsState>(
              bloc: currentAccountsBloc,
              builder: (context, state) => state.maybeWhen(
                ready: (accounts, currentAccount) => WalletScaffold(
                  modalController: modalController,
                  body: WalletBody(
                    accounts: accounts,
                    currentAccount: currentAccount,
                    modalController: modalController,
                    bloc: currentAccountsBloc,
                  ),
                  modalBody: (controller) => currentAccount != null
                      ? WalletModalBody(
                          key: ValueKey(currentAccount.address),
                          address: currentAccount.address,
                          scrollController: controller,
                          onTabSelected: (_) => modalController.resetScroll(),
                        )
                      : const SizedBox(),
                ),
                orElse: () => const SizedBox(),
              ),
            ),
          ),
        ),
      );
}
