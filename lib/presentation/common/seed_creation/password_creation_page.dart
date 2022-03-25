import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:validators/validators.dart';

import '../../../../../injection.dart';
import '../../../../data/repositories/biometry_repository.dart';
import '../../../../data/repositories/keys_repository.dart';
import '../../../../injection.dart';
import '../../../../providers/biometry/biometry_availability_provider.dart';
import '../../../../providers/biometry/biometry_status_provider.dart';
import '../../../data/extensions.dart';
import '../../../generated/codegen_loader.g.dart';
import '../../router.gr.dart';
import '../theme.dart';
import '../widgets/crystal_flushbar.dart';
import '../widgets/crystal_subtitle.dart';
import '../widgets/crystal_title.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/custom_checkbox.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/text_field_clear_button.dart';
import '../widgets/unfocusing_gesture_detector.dart';

class PasswordCreationPage extends StatefulWidget {
  final List<String> phrase;
  final String? seedName;

  const PasswordCreationPage({
    Key? key,
    required this.phrase,
    this.seedName,
  }) : super(key: key);

  @override
  State<PasswordCreationPage> createState() => _PasswordCreationPageState();
}

class _PasswordCreationPageState extends State<PasswordCreationPage> {
  final scrollController = ScrollController();
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final repeatController = TextEditingController();
  final passwordFocusNode = FocusNode();
  final repeatFocusNode = FocusNode();
  final formValidityNotifier = ValueNotifier<String?>('');

  @override
  void dispose() {
    scrollController.dispose();
    passwordController.dispose();
    repeatController.dispose();
    passwordFocusNode.dispose();
    repeatFocusNode.dispose();
    formValidityNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: UnfocusingGestureDetector(
          child: Scaffold(
            appBar: AppBar(
              leading: const CustomBackButton(),
            ),
            body: body(),
          ),
        ),
      );

  Widget body() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16) - const EdgeInsets.only(top: 16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    title(),
                    const SizedBox(height: 16),
                    subtitle(),
                    const SizedBox(height: 32),
                    fields(),
                    const SizedBox(height: 64),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    submitButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget title() => CrystalTitle(
        text: LocaleKeys.password_creation_screen_creation_title.tr(),
      );

  Widget subtitle() => CrystalSubtitle(
        text: LocaleKeys.password_creation_screen_creation_description.tr(),
      );

  Widget fields() => Form(
        key: formKey,
        onChanged: onChanged,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            passwordField(),
            const SizedBox(height: 16),
            repeatField(),
            validationText(),
            if (context.router.routeData.name != NewSeedRouterRoute.name) biometryCheckbox(),
          ],
        ),
      );

  void onChanged() {
    formKey.currentState?.validate();

    String? text;

    if (repeatController.text.isEmpty) {
      text = '';
    }

    if (!isLength(passwordController.text, 8)) {
      text = 'Password must be at least 8 symbols';
    } else if (repeatController.text.isNotEmpty && passwordController.text != repeatController.text) {
      text = 'Passwords must match';
    }

    if (passwordController.text.isEmpty && repeatController.text.isEmpty) {
      text = '';
    }

    formValidityNotifier.value = text;
  }

  Widget passwordField() => CustomTextFormField(
        name: 'password',
        controller: passwordController,
        focusNode: passwordFocusNode,
        autocorrect: false,
        enableSuggestions: false,
        obscureText: true,
        textInputAction: TextInputAction.next,
        hintText: LocaleKeys.password_creation_screen_password_hint.tr(),
        suffixIcon: TextFieldClearButton(
          controller: passwordController,
        ),
        onSubmitted: (value) => repeatFocusNode.requestFocus(),
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return null;
          }

          if (!isLength(value, 8)) {
            return value;
          }
          return null;
        },
      );

  Widget repeatField() => CustomTextFormField(
        name: 'repeat',
        controller: repeatController,
        focusNode: repeatFocusNode,
        autocorrect: false,
        enableSuggestions: false,
        obscureText: true,
        textInputAction: TextInputAction.done,
        hintText: LocaleKeys.password_creation_screen_password_confirmation.tr(),
        suffixIcon: TextFieldClearButton(
          controller: repeatController,
        ),
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return null;
          }

          if (passwordController.text != value) {
            return value;
          }
          return null;
        },
      );

  Widget validationText() => ValueListenableBuilder<String?>(
        valueListenable: formValidityNotifier,
        builder: (context, value, child) => value != null && value.isNotEmpty
            ? Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: CrystalColor.error,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.25,
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox(),
      );

  Widget biometryCheckbox() => Consumer(
        builder: (context, ref, child) {
          final isEnabled = ref.watch(biometryStatusProvider).asData?.value ?? false;
          final isAvailable = ref.watch(biometryAvailabilityProvider).asData?.value ?? false;

          return !isAvailable
              ? const SizedBox()
              : Column(
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CustomCheckbox(
                          value: isEnabled,
                          onChanged: (value) => getIt.get<BiometryRepository>().setStatus(
                                localizedReason: 'Please authenticate to interact with wallet',
                                isEnabled: !isEnabled,
                              ),
                        ),
                        Expanded(
                          child: Text(LocaleKeys.biometry_checkbox.tr()),
                        ),
                      ],
                    ),
                  ],
                );
        },
      );

  Widget submitButton() => ValueListenableBuilder<String?>(
        valueListenable: formValidityNotifier,
        builder: (context, value, child) => CustomElevatedButton(
          onPressed: value != null ? null : onSubmitButtonPressed,
          text: LocaleKeys.actions_confirm.tr(),
        ),
      );

  Future<void> onSubmitButtonPressed() async {
    try {
      final password = passwordController.text;

      await getIt.get<KeysRepository>().createKey(
            name: widget.seedName,
            phrase: widget.phrase,
            password: password,
          );

      if (context.router.routeData.name == NewSeedRouterRoute.name) {
        context.router.navigate(const ProfileRouterRoute());
      }
    } catch (err) {
      showErrorCrystalFlushbar(
        context,
        message: (err as Exception).toUiMessage(),
      );
    }
  }
}
