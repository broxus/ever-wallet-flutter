import 'package:ever_wallet/application/adding_seed_to_app/enter_seed_phrase/enter_seed_phrase_widget.dart';
import 'package:ever_wallet/application/onboarding/general_screens/create_password.dart';
import 'package:ever_wallet/application/onboarding/widgets/onboarding_background.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:flutter/material.dart';

class EnterOnboardingSeedPhraseRoute extends MaterialPageRoute<void> {
  EnterOnboardingSeedPhraseRoute() : super(builder: (_) => const EnterOnboardingSeedPhraseScreen());
}

class EnterOnboardingSeedPhraseScreen extends StatelessWidget {
  const EnterOnboardingSeedPhraseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingBackground(
      child: EnterSeedPhraseWidget(
        callback: (BuildContext context, List<String> phrase) {
          Navigator.of(context).push(CreatePasswordOnboardingRoute(phrase));
        },
        errorColor: ColorsRes.redDark,
        inactiveBorderColor: ColorsRes.white.withOpacity(0.24),
        secondaryTextColor: ColorsRes.white,
        primaryColor: ColorsRes.lightBlue,
        defaultTextColor: ColorsRes.white,
        buttonTextColor: ColorsRes.black,
        suggestionBackgroundColor: ColorsRes.black.withOpacity(0.9),
      ),
    );
  }
}
