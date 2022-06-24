import 'package:flutter/material.dart';

import '../../../generated/assets.gen.dart';
import '../../common/general/button/primary_button.dart';
import '../../common/general/default_appbar.dart';
import '../../common/general/field/checkbox_input_field.dart';
import '../../util/extensions/context_extensions.dart';
import '../widgets/onboarding_background.dart';

class AgreeDecentralizationRoute extends MaterialPageRoute {
  AgreeDecentralizationRoute() : super(builder: (_) => const AgreeDecentralizationScreen());
}

class AgreeDecentralizationScreen extends StatelessWidget {
  const AgreeDecentralizationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.themeStyle;
    final localization = context.localization;
    final size = MediaQuery.of(context).size;

    return OnboardingBackground(
      otherPositioned: [
        Positioned(
          top: kToolbarHeight,
          left: 0,
          right: 0,
          height: size.height * 0.5,
          child: Assets.images.onboarding.decentralisationSign.svg(),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const DefaultAppBar(),
        body: SafeArea(
          minimum: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text(localization.sign_policy, style: themeStyle.styles.fullScreenStyle),
                const SizedBox(height: 40),
                CheckboxInputField(
                  text: Text(
                    localization.policy_description,
                    style: themeStyle.styles.captionStyle,
                  ),
                  value: false,
                  onChanged: (v) {},
                ),
                const SizedBox(height: 40),
                PrimaryButton(
                  text: localization.submit,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
