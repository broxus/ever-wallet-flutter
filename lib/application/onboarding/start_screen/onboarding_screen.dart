import 'package:ever_wallet/application/common/general/button/primary_button.dart';
import 'package:ever_wallet/application/common/utils.dart';
import 'package:ever_wallet/application/onboarding/create_wallet/save_seed_phrase_screen.dart';
import 'package:ever_wallet/application/onboarding/sign_with_phrase/enter_seed_phrase_screen.dart';
import 'package:ever_wallet/application/onboarding/start_screen/widgets/sliding_block_chains.dart';
import 'package:ever_wallet/application/onboarding/widgets/onboarding_background.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
          minimum: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Expanded(child: SlidingBlockChains()),
              const SizedBox(height: 20),
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
                    const SizedBox(height: 32),
                    PrimaryButton(
                      text: context.localization.create_new_wallet,
                      onPressed: () => Navigator.of(context).push(SaveSeedPhraseRoute()),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      text: context.localization.sign_in,
                      onPressed: () => Navigator.of(context).push(EnterSeedPhraseRoute()),
                      isTransparent: true,
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      text: 'Sign in with Ledger',
                      // TODO: change icon
                      icon: Assets.images.ledger.svg(
                        color: style.styles.secondaryButtonStyle.color,
                      ),
                      onPressed: () {},
                      isTransparent: true,
                    ),
                    const SizedBox(height: 16),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'By proceeding, you accept EVER Wallet License Agreement. ',
                            style: style.styles.basicStyle,
                          ),
                          TextSpan(
                            text: 'Read here',
                            style:
                                style.styles.basicStyle.copyWith(color: ColorsRes.bluePrimary400),
                            recognizer: TapGestureRecognizer()..onTap = onLinkTap,
                          ),
                        ],
                      ),
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

  void onLinkTap() => launchUrlString(decentralizationPolicyLink);
}
