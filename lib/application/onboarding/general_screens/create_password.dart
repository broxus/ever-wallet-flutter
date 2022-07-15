import 'package:ever_wallet/application/application.dart';
import 'package:ever_wallet/application/common/general/button/primary_button.dart';
import 'package:ever_wallet/application/common/general/field/bordered_input.dart';
import 'package:ever_wallet/application/common/general/onboarding_appbar.dart';
import 'package:ever_wallet/application/onboarding/widgets/onboarding_background.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          appBar: const OnboardingAppBar(),
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
                    onSubmitted: (_) => _nextAction(Navigator.of(context)),
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
                    onPressed: () => _nextAction(Navigator.of(context)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _nextAction(NavigatorState navigator) async {
    if (formKey.currentState?.validate() ?? false) {
      await context.read<KeysRepository>().createKey(
            name: widget.seedName,
            phrase: widget.phrase,
            password: passwordController.text,
          );

      navigator.pushNamedAndRemoveUntil(AppRouter.main, (route) => false);
    }
  }
}
