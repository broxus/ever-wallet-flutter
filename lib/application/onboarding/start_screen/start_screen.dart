import 'package:ever_wallet/application/common/general/button/primary_button.dart';
import 'package:ever_wallet/application/onboarding/general_screens/agree_decentralization_screen.dart';
import 'package:ever_wallet/application/onboarding/start_screen/widgets/sliding_block_chains.dart';
import 'package:ever_wallet/application/onboarding/widgets/onboarding_background.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';

class OnboardingScreenRoute extends MaterialPageRoute<void> {
  OnboardingScreenRoute() : super(builder: (_) => const OnboardingScreen());
}

/// Entry point in the app if user not authenticated
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = context.themeStyle;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: OnboardingBackground(
        child: SafeArea(
          minimum: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Expanded(child: SlidingBlockChains()),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.localization.welcome_title,
                      style: style.styles.fullScreenStyle,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      // TODO: replace text
                      'Support of any token and access to the DApps of Everscale blockchain ecosystem',
                      style: style.styles.basicStyle,
                    ),
                    const SizedBox(height: 48),
                    PrimaryButton(
                      text: context.localization.create_new_wallet,
                      onPressed: () => Navigator.of(context)
                          .push(AgreeDecentralizationRoute(AuthType.createNewWallet)),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      text: context.localization.sign_in,
                      onPressed: () => Navigator.of(context)
                          .push(AgreeDecentralizationRoute(AuthType.signWithSeedPhrase)),
                      isTransparent: true,
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      text: 'Ledger',
                      // TODO: change icon
                      icon: Assets.images.iconQr.svg(
                        color: style.styles.secondaryButtonStyle.color,
                      ),
                      onPressed: () {},
                      isTransparent: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
