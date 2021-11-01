import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
