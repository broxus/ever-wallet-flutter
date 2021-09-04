import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/blocs/subscription/subscriptions_bloc.dart';
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
  final subscriptionsBloc = getIt.get<SubscriptionsBloc>();

  @override
  void dispose() {
    modalController.close();
    subscriptionsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: ColoredBox(
          color: CrystalColor.background,
          child: AnimatedAppearance(
            child: BlocBuilder<SubscriptionsBloc, SubscriptionsState>(
              bloc: subscriptionsBloc,
              builder: (context, state) => state.maybeWhen(
                ready: (subscriptions, currentSubscription) => WalletScaffold(
                  modalController: modalController,
                  body: WalletBody(
                    subscriptions: subscriptions,
                    subscriptionSubject: currentSubscription,
                    modalController: modalController,
                    bloc: subscriptionsBloc,
                  ),
                  modalBody: (controller) => currentSubscription != null
                      ? WalletModalBody(
                          key: ValueKey(currentSubscription),
                          subscriptionSubject: currentSubscription,
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
