import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../domain/blocs/subscription/subscriptions_bloc.dart';
import '../../../design/design.dart';
import '../../../router.gr.dart';
import 'profile_actions.dart';
import 'profile_carousel.dart';

class WalletBody extends StatelessWidget {
  final List<SubscriptionSubject> subscriptions;
  final SubscriptionSubject? subscriptionSubject;
  final PanelController modalController;
  final SubscriptionsBloc bloc;

  const WalletBody({
    Key? key,
    required this.subscriptions,
    required this.subscriptionSubject,
    required this.modalController,
    required this.bloc,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LocaleKeys.wallet_screen_title.tr(),
                        style: const TextStyle(
                          fontSize: 30,
                          letterSpacing: 0.25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.router.navigate(const SettingsRouterRoute()),
                        icon: const Icon(
                          Icons.person,
                          size: 30,
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
                    subscriptions: subscriptions,
                    onPageChanged: (i) {
                      if (i < subscriptions.length) {
                        bloc.add(SubscriptionsEvent.setCurrentSubscription(subscriptions[i]));
                      } else {
                        modalController.hide();
                        bloc.add(const SubscriptionsEvent.setCurrentSubscription(null));
                      }
                    },
                    onPageSelected: (i) {
                      if (i == subscriptions.length) {
                        modalController.hide();
                      } else {
                        modalController.show();
                      }
                    },
                  ),
                ),
                const CrystalDivider(height: 16),
                if (subscriptionSubject != null)
                  ProfileActions(
                    key: ValueKey(subscriptionSubject),
                    subscriptionSubject: subscriptionSubject!,
                  ),
                const CrystalDivider(height: 20),
              ],
            ),
          ),
        ),
      );
}
