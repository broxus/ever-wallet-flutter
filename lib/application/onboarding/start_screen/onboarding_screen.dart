import 'package:ever_wallet/application/common/general/button/primary_button.dart';
import 'package:ever_wallet/application/common/utils.dart';
import 'package:ever_wallet/application/onboarding/create_wallet/save_seed_phrase_screen.dart';
import 'package:ever_wallet/application/onboarding/sign_with_phrase/enter_seed_phrase_screen.dart';
import 'package:ever_wallet/application/onboarding/start_screen/widgets/sliding_block_chains.dart';
import 'package:ever_wallet/application/onboarding/widgets/onboarding_background.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Entry point in the app if user not authenticated
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final style = context.themeStyle;
    final localization = context.localization;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
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
                        localization.support_token_and_access_everscale,
                        style: style.styles.basicStyle,
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        text: context.localization.create_new_wallet,
                        onPressed: () => Navigator.of(context).push(SaveSeedPhraseOnboardingRoute()),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        text: context.localization.sign_in,
                        onPressed: () => Navigator.of(context).push(EnterOnboardingSeedPhraseRoute()),
                        isTransparent: true,
                      ),
                      // const SizedBox(height: 12),
                      // PrimaryButton(
                      //   text: localization.sign_with_ledger,
                      //   // TODO: change icon
                      //   icon: Assets.images.ledger.svg(
                      //     color: style.styles.secondaryButtonStyle.color,
                      //   ),
                      //   onPressed: () {},
                      //   isTransparent: true,
                      // ),
                      const SizedBox(height: 16),
                      Text.rich(
                        TextSpan(
                          children: [
                            ..._buildTermsAndPrivacy(context),
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
      ),
    );
  }

  Iterable<TextSpan> _buildTermsAndPrivacy(BuildContext context) {
    final style = context.themeStyle;
    final localization = context.localization;

    return localization.by_processing_accept_license
        .split(':')
        .map((text) {
      if (text == 'terms_of_use') {
        return TextSpan(
          text: localization.terms_of_use,
          style: style.styles.basicStyle.copyWith(
            color: ColorsRes.bluePrimary400,
          ),
          recognizer: TapGestureRecognizer()..onTap = onTermsLinkTap,
        );
      }
      if (text == 'privacy_policy') {
        return TextSpan(
          text: localization.privacy_policy,
          style: style.styles.basicStyle.copyWith(
            color: ColorsRes.bluePrimary400,
          ),
          recognizer: TapGestureRecognizer()..onTap = onPrivacyLinkTap,
        );
      }

      return TextSpan(
        text: text,
        style: style.styles.basicStyle,
      );
    });
  }

  void onTermsLinkTap() =>
      launchUrlString(termsOfUseLink, mode: LaunchMode.externalApplication);

  void onPrivacyLinkTap() =>
      launchUrlString(privacyPolicyLink, mode: LaunchMode.externalApplication);
}
