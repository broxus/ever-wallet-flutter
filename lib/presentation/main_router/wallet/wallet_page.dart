import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/blocs/account/accounts_bloc.dart';
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

  @override
  void dispose() {
    modalController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: ColoredBox(
          color: CrystalColor.background,
          child: AnimatedAppearance(
            child: BlocBuilder<AccountsBloc, AccountsState>(
              bloc: context.watch<AccountsBloc>(),
              builder: (context, state) => WalletScaffold(
                modalController: modalController,
                body: WalletBody(
                  accounts: state.accounts,
                  currentAccount: state.currentAccount,
                  modalController: modalController,
                ),
                modalBody: (controller) => state.currentAccount != null
                    ? WalletModalBody(
                        address: state.currentAccount!.address,
                        scrollController: controller,
                        onTabSelected: (_) => modalController.resetScroll(),
                      )
                    : const SizedBox(),
              ),
            ),
          ),
        ),
      );
}
