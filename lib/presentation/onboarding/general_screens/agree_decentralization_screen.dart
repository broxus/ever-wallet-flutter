import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../generated/assets.gen.dart';
import '../../common/general/button/primary_button.dart';
import '../../common/general/onboarding_appbar.dart';
import '../../common/general/field/checkbox_input_field.dart';
import '../../common/utils.dart';
import '../../util/extensions/context_extensions.dart';
import '../widgets/onboarding_background.dart';
import 'seed_phrase_name_screen.dart';

enum AuthType { createNewWallet, signWithSeedPhrase }

class AgreeDecentralizationRoute extends MaterialPageRoute<void> {
  AgreeDecentralizationRoute(AuthType type)
      : super(builder: (_) => AgreeDecentralizationScreen(type: type));
}

class AgreeDecentralizationScreen extends StatefulWidget {
  final AuthType type;

  const AgreeDecentralizationScreen({
    Key? key,
    required this.type,
  }) : super(key: key);

  @override
  State<AgreeDecentralizationScreen> createState() => _AgreeDecentralizationScreenState();
}

class _AgreeDecentralizationScreenState extends State<AgreeDecentralizationScreen> {
  final agreeNotifier = ValueNotifier<bool>(false);
  final formKey = GlobalKey<FormState>();

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
        appBar: const OnboardingAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(localization.sign_policy, style: themeStyle.styles.fullScreenStyle),
              const SizedBox(height: 40),
              Form(
                key: formKey,
                child: ValueListenableBuilder<bool>(
                  valueListenable: agreeNotifier,
                  builder: (_, agreed, __) {
                    return CheckboxInputField(
                      needValidation: true,
                      text: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: localization.policy_description,
                              style: themeStyle.styles.captionStyle,
                            ),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: onLinkTap,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(width: 5),
                                    Text(
                                      localization.link,
                                      style: themeStyle.styles.captionStyle.copyWith(
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      Icons.link,
                                      color: themeStyle.styles.captionStyle.color,
                                      size: themeStyle.styles.captionStyle.fontSize! + 5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      value: agreed,
                      onChanged: (v) {
                        formKey.currentState?.reset();
                        agreeNotifier.value = v;
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                text: localization.submit,
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    Navigator.of(context).push(SeedPhraseNameRoute(widget.type));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onLinkTap() => launchUrlString(decentralizationPolicyLink);
}
