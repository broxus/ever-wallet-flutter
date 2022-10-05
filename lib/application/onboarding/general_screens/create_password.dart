import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/general/button/primary_button.dart';
import 'package:ever_wallet/application/common/general/field/bordered_input.dart';
import 'package:ever_wallet/application/common/general/field/switch_field.dart';
import 'package:ever_wallet/application/common/general/onboarding_appbar.dart';
import 'package:ever_wallet/application/onboarding/sign_with_phrase/select_phrase_type_screen.dart';
import 'package:ever_wallet/application/onboarding/widgets/onboarding_background.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/data/repositories/biometry_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

const kPasswordInputHeight = 52.0;

class CreatePasswordRoute extends MaterialPageRoute<void> {
  CreatePasswordRoute(
    List<String> phrase,
  ) : super(builder: (_) => CreatePasswordScreen(phrase: phrase));
}

class CreatePasswordScreen extends StatefulWidget {
  final List<String> phrase;

  const CreatePasswordScreen({
    super.key,
    required this.phrase,
  });

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
                  getBiometricSwitcher(),
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

  Widget getBiometricSwitcher() {
    // final localization = context.localization;
    final themeStyle = context.themeStyle;

    return StreamProvider<AsyncValue<bool>>(
      create: (context) => context
          .read<BiometryRepository>()
          .availabilityStream
          .map((event) => AsyncValue.ready(event)),
      initialData: const AsyncValue.loading(),
      catchError: (context, error) => AsyncValue.error(error),
      builder: (context, child) {
        final isAvailable = context.watch<AsyncValue<bool>>().maybeWhen(
              ready: (value) => value,
              orElse: () => false,
            );

        return !isAvailable
            ? const SizedBox()
            : Container(
                color: ColorsRes.lightBlue.withOpacity(0.1),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        // TODO: replace text
                        'Use Biometry for fast login',
                        style: themeStyle.styles.basicStyle,
                      ),
                    ),
                    const Gap(16),
                    StreamProvider<AsyncValue<bool>>(
                      create: (context) => context
                          .read<BiometryRepository>()
                          .statusStream
                          .map((event) => AsyncValue.ready(event)),
                      initialData: const AsyncValue.loading(),
                      catchError: (context, error) => AsyncValue.error(error),
                      builder: (context, child) {
                        final isEnabled = context.watch<AsyncValue<bool>>().maybeWhen(
                              ready: (value) => value,
                              orElse: () => false,
                            );

                        return EWSwitchField(
                          value: isEnabled,
                          onChanged: (value) => context.read<BiometryRepository>().setStatus(
                                localizedReason: context.localization.authentication_reason,
                                isEnabled: !isEnabled,
                              ),
                        );
                      },
                    ),
                  ],
                ),
              );
      },
    );
  }

  Future<void> _nextAction(NavigatorState navigator) async {
    if (formKey.currentState?.validate() ?? false) {
      final key = await context
          .read<KeysRepository>()
          .createKey(phrase: widget.phrase, password: passwordController.text);

      /// TODO: add logic to check existed accounts for key
      navigator.push(SelectPhraseTypeRute(key.publicKey));
      // navigator.pushNamedAndRemoveUntil(AppRouter.main, (route) => false);
    }
  }
}
