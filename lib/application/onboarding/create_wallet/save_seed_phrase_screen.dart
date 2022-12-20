import 'package:ever_wallet/application/adding_seed_to_app/create_wallet/create_seed_widget.dart';
import 'package:ever_wallet/application/onboarding/create_wallet/check_seed_phase_screen.dart';
import 'package:ever_wallet/application/onboarding/general_screens/create_password.dart';
import 'package:ever_wallet/application/onboarding/widgets/onboarding_background.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:flutter/material.dart';

class SaveSeedPhraseOnboardingRoute extends MaterialPageRoute<void> {
  SaveSeedPhraseOnboardingRoute() : super(builder: (_) => const SaveSeedPhraseOnboardingScreen());
}

/// !!! Here displays only 12 words
class SaveSeedPhraseOnboardingScreen extends StatelessWidget {
  const SaveSeedPhraseOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingBackground(
      child: CreateSeedWidget(
        checkCallback: (BuildContext context, List<String> phrase) {
          Navigator.of(context).push(CheckSeedPhraseOnboardingRoute(phrase));
        },
        skipCallback: (BuildContext context, List<String> phrase) {
          Navigator.of(context).push(CreatePasswordOnboardingRoute(phrase));
        },
        phraseBackgroundColor: ColorsRes.lightBlue.withOpacity(0.08),
        secondaryTextColor: ColorsRes.white,
        defaultTextColor: ColorsRes.white,
        primaryColor: ColorsRes.lightBlue,
        skipButtonColor: const Color(0xFF253056),
        checkButtonTextColor: ColorsRes.black,
        needSkipButtonBorder: false,
      ),
    );
  }
}
