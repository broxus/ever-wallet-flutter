import 'package:beamer/beamer.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/crystal_flushbar.dart';
import 'package:ever_wallet/application/common/widgets/crystal_subtitle.dart';
import 'package:ever_wallet/application/common/widgets/crystal_title.dart';
import 'package:ever_wallet/application/common/widgets/custom_back_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_checkbox.dart';
import 'package:ever_wallet/application/common/widgets/custom_elevated_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_text_form_field.dart';
import 'package:ever_wallet/application/common/widgets/text_field_clear_button.dart';
import 'package:ever_wallet/application/common/widgets/unfocusing_gesture_detector.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/repositories/biometry_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart';

class PasswordCreationScreen extends StatefulWidget {
  final List<String> phrase;
  final String? seedName;
  final bool fromWizard;

  const PasswordCreationScreen({
    Key? key,
    required this.phrase,
    this.seedName,
    required this.fromWizard,
  }) : super(key: key);

  @override
  State<PasswordCreationScreen> createState() => _PasswordCreationScreenState();
}

class _PasswordCreationScreenState extends State<PasswordCreationScreen> {
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
                    const Gap(8),
                    title(),
                    const Gap(16),
                    subtitle(),
                    const Gap(32),
                    fields(),
                    const Gap(64),
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
        text: AppLocalizations.of(context)!.create_password,
      );

  Widget subtitle() => CrystalSubtitle(
        text: AppLocalizations.of(context)!.create_password_description,
      );

  Widget fields() => Form(
        key: formKey,
        onChanged: onChanged,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            passwordField(),
            const Gap(16),
            repeatField(),
            validationText(),
            if (widget.fromWizard) biometryCheckbox(),
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
      text = AppLocalizations.of(context)!.password_length;
    } else if (repeatController.text.isNotEmpty &&
        passwordController.text != repeatController.text) {
      text = AppLocalizations.of(context)!.passwords_match;
    }

    if (passwordController.text.isEmpty && repeatController.text.isEmpty) {
      text = '';
    }

    formValidityNotifier.value = text;
  }

  Widget passwordField() => CustomTextFormField(
        name: AppLocalizations.of(context)!.password,
        controller: passwordController,
        focusNode: passwordFocusNode,
        autocorrect: false,
        enableSuggestions: false,
        obscureText: true,
        textInputAction: TextInputAction.next,
        hintText: AppLocalizations.of(context)!.your_password,
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
        name: AppLocalizations.of(context)!.repeat,
        controller: repeatController,
        focusNode: repeatFocusNode,
        autocorrect: false,
        enableSuggestions: false,
        obscureText: true,
        textInputAction: TextInputAction.done,
        hintText: AppLocalizations.of(context)!.confirm_password,
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
                  const Gap(16),
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

  Widget biometryCheckbox() => StreamProvider<AsyncValue<bool>>(
        create: (context) => context
            .read<BiometryRepository>()
            .availabilityStream
            .map((event) => AsyncValue.ready(event)),
        initialData: const AsyncValue.loading(),
        catchError: (context, error) => AsyncValue.error(error),
        builder: (context, child) => context.watch<AsyncValue<bool>>().maybeWhen(
              ready: (value) => !value
                  ? const SizedBox()
                  : Column(
                      children: [
                        const Gap(16),
                        StreamProvider<AsyncValue<bool>>(
                          create: (context) => context
                              .read<BiometryRepository>()
                              .statusStream
                              .map((event) => AsyncValue.ready(event)),
                          initialData: const AsyncValue.loading(),
                          catchError: (context, error) => AsyncValue.error(error),
                          builder: (context, child) => context.watch<AsyncValue<bool>>().maybeWhen(
                                ready: (value) => Row(
                                  children: [
                                    CustomCheckbox(
                                      value: value,
                                      onChanged: (_) =>
                                          context.read<BiometryRepository>().setStatus(
                                                localizedReason: AppLocalizations.of(context)!
                                                    .authentication_reason,
                                                isEnabled: !value,
                                              ),
                                    ),
                                    Expanded(
                                      child: Text(AppLocalizations.of(context)!.enable_biometry),
                                    ),
                                  ],
                                ),
                                orElse: () => const SizedBox(),
                              ),
                        ),
                      ],
                    ),
              orElse: () => const SizedBox(),
            ),
      );

  Widget submitButton() => ValueListenableBuilder<String?>(
        valueListenable: formValidityNotifier,
        builder: (context, value, child) => CustomElevatedButton(
          onPressed: value != null ? null : onSubmitButtonPressed,
          text: AppLocalizations.of(context)!.confirm,
        ),
      );

  Future<void> onSubmitButtonPressed() async {
    try {
      final password = passwordController.text;

      await context.read<KeysRepository>().createKey(
            name: widget.seedName,
            phrase: widget.phrase,
            password: password,
          );

      if (!widget.fromWizard) {
        if (!mounted) return;
        context.beamToNamed('/main/profile');
      } else {
        if (!mounted) return;
        context.beamToNamed('/main');
      }
    } catch (err) {
      showErrorCrystalFlushbar(
        context,
        message: (err as Exception).toUiMessage(),
      );
    }
  }
}
