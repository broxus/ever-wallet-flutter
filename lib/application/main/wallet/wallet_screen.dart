import 'package:ever_wallet/application/bloc/account/current_account_cubit.dart';
import 'package:ever_wallet/application/common/widgets/animated_appearance.dart';
import 'package:ever_wallet/application/common/widgets/sliding_panel.dart';
import 'package:ever_wallet/application/main/wallet/history/wallet_modal_body.dart';
import 'package:ever_wallet/application/main/wallet/widgets/wallet_body.dart';
import 'package:ever_wallet/application/main/wallet/widgets/wallet_scaffold.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletScreenRoute extends MaterialPageRoute<void> {
  WalletScreenRoute() : super(builder: (_) => const WalletScreen());
}

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final modalController = PanelController(initialState: PanelState.hidden);

  @override
  void dispose() {
    modalController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: AnimatedAppearance(
          child: BlocProvider<CurrentAccountCubit>(
            create: (context) => CurrentAccountCubit(context.read<AccountsRepository>()),
            child: WalletScaffold(
              modalController: modalController,
              body: WalletBody(
                modalController: modalController,
              ),
              modalBody: (controller) => WalletModalBody(
                scrollController: controller,
                onTabSelected: (_) => modalController.resetScroll(),
              ),
            ),
          ),
        ),
      );
}
