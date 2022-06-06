import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers/account/accounts_provider.dart';
import '../../../../../providers/account/current_account_provider.dart';
import '../../../common/widgets/animated_appearance.dart';
import '../../../common/widgets/sliding_panel.dart';
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
                      AppLocalizations.of(context)!.wallet,
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
                child: Consumer(
                  builder: (context, ref, child) {
                    final accounts = ref.watch(accountsProvider).asData?.value ?? [];

                    return ProfileCarousel(
                      accounts: accounts,
                      onPageChanged: (i) {
                        if (i < accounts.length) {
                          ref.read(currentAccountProvider.notifier).setCurrent(accounts[i].address);
                        } else {
                          modalController.hide();

                          ref.read(currentAccountProvider.notifier).setCurrent(null);
                        }
                      },
                      onPageSelected: (i) {
                        if (i == accounts.length) {
                          modalController.hide();
                        } else {
                          modalController.show();
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  final currentAccount = ref.watch(currentAccountProvider);

                  return currentAccount != null ? ProfileActions(address: currentAccount.address) : const SizedBox();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
}
