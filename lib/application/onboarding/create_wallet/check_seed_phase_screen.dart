import 'package:ever_wallet/application/adding_seed_to_app/check_seed_phrase/check_seed_phrase_widget.dart';
import 'package:ever_wallet/application/onboarding/general_screens/create_password.dart';
import 'package:ever_wallet/application/onboarding/widgets/onboarding_background.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:flutter/material.dart';

class CheckSeedPhraseOnboardingRoute extends MaterialPageRoute<void> {
  CheckSeedPhraseOnboardingRoute(List<String> phrase)
      : super(builder: (_) => CheckSeedPhraseOnboardingScreen(phrase: phrase));
}

class CheckSeedPhraseOnboardingScreen extends StatelessWidget {
  final List<String> phrase;

  const CheckSeedPhraseOnboardingScreen({
    super.key,
    required this.phrase,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingBackground(
      child: CheckSeedPhraseWidget(
        phrase: phrase,
        navigateToPassword: (context) => Navigator.of(context).push(
          CreatePasswordOnboardingRoute(phrase),
        ),
        primaryColor: ColorsRes.lightBlue,
        defaultTextColor: ColorsRes.white,
        secondaryTextColor: ColorsRes.white,
        defaultBorderColor: ColorsRes.white.withOpacity(0.24),
        errorColor: ColorsRes.redLight,
        availableAnswersTextColor: ColorsRes.white,
        notSelectedTextColor: ColorsRes.grey,
      ),
    );
  }
}
