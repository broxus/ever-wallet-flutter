import 'package:flutter/material.dart';

import '../../common/general/button/primary_button.dart';
import '../../common/general/default_appbar.dart';
import '../../common/general/field/bordered_input.dart';
import '../../util/extensions/context_extensions.dart';
import '../widgets/onboarding_background.dart';

const kPasswordInputHeight = 52.0;

class CreatePasswordRoute extends MaterialPageRoute<void> {
  CreatePasswordRoute(
    List<String> phrase,
    String seedName,
  ) : super(
          builder: (_) => CreatePasswordScreen(phrase: phrase, seedName: seedName),
        );
}

class CreatePasswordScreen extends StatefulWidget {
  final List<String> phrase;
  final String seedName;

  const CreatePasswordScreen({
    Key? key,
    required this.phrase,
    required this.seedName,
  }) : super(key: key);

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  final passwordFocus = FocusNode();
  final confirmFocus = FocusNode();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.themeStyle;
    final localization = context.localization;

    return OnboardingBackground(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: const DefaultAppBar(),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(localization.create_password, style: themeStyle.styles.appbarStyle),
                  const SizedBox(height: 16),
                  Text(
                    localization.create_password_description,
                    style: themeStyle.styles.basicStyle,
                  ),
                  const SizedBox(height: 32),
                  BorderedInput(
                    obscureText: true,
                    height: kPasswordInputHeight,
                    controller: passwordController,
                    focusNode: passwordFocus,
                    label: localization.your_password,
                    onSubmitted: (_) => confirmFocus.requestFocus(),
                    validator: (_) {
                      if (passwordController.text.length >= 8) {
                        return null;
                      }
                      return localization.password_length;
                    },
                  ),
                  const SizedBox(height: 12),
                  BorderedInput(
                    obscureText: true,
                    height: kPasswordInputHeight,
                    controller: confirmController,
                    focusNode: confirmFocus,
                    label: localization.confirm_password,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _nextAction(),
                    validator: (_) {
                      if (confirmController.text == passwordController.text) {
                        return null;
                      }

                      return localization.passwords_match;
                    },
                  ),
                  const SizedBox(height: 12),
                  const Spacer(),
                  PrimaryButton(
                    text: localization.next,
                    onPressed: _nextAction,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _nextAction() {
    if (formKey.currentState?.validate() ?? false) {
      // TODO: do action
    }
  }
}