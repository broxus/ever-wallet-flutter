import 'package:ever_wallet/application/adding_seed_to_app/create_password/create_seed_password_widget.dart';
import 'package:ever_wallet/application/application.dart';
import 'package:ever_wallet/application/onboarding/widgets/onboarding_background.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:flutter/material.dart';

class CreatePasswordOnboardingRoute extends MaterialPageRoute<void> {
  CreatePasswordOnboardingRoute(
    List<String> phrase,
  ) : super(builder: (_) => CreatePasswordOnboardingScreen(phrase: phrase));
}

class CreatePasswordOnboardingScreen extends StatelessWidget {
  const CreatePasswordOnboardingScreen({
    super.key,
    required this.phrase,
  });

  final List<String> phrase;

  @override
  Widget build(BuildContext context) {
    return OnboardingBackground(
      child: CreateSeedPasswordWidget(
        phrase: phrase,
        name: null,
        callback: (BuildContext context) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.main, (route) => false);
        },
        setCurrentKey: true,
        primaryColor: ColorsRes.lightBlue,
        defaultTextColor: ColorsRes.white,
        secondaryTextColor: ColorsRes.white,
        buttonTextColor: ColorsRes.black,
        errorColor: ColorsRes.redDark,
        needBiometryIfPossible: true,
      ),
    );
  }
}
