import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:validators/validators.dart';

import '../../../../../domain/blocs/biometry/biometry_info_bloc.dart';
import '../../../../../domain/blocs/key/key_creation_bloc.dart';
import '../../../../../injection.dart';
import '../../../../injection.dart';
import '../../../design/design.dart';
import '../../../design/widgets/crystal_subtitle.dart';
import '../../../design/widgets/crystal_title.dart';
import '../../../design/widgets/custom_app_bar.dart';
import '../../../design/widgets/custom_checkbox.dart';
import '../../../design/widgets/custom_elevated_button.dart';
import '../../../design/widgets/custom_text_form_field.dart';
import '../../../design/widgets/text_suffix_icon_button.dart';
import '../../../design/widgets/unfocusing_gesture_detector.dart';
import '../../router.gr.dart';

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
  final formValidityNotifier = ValueNotifier<String?>('');
  final bloc = getIt.get<KeyCreationBloc>();

  @override
  void dispose() {
    scrollController.dispose();
    passwordController.dispose();
    repeatController.dispose();
    formValidityNotifier.dispose();
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocListener<KeyCreationBloc, KeyCreationState>(
        bloc: bloc,
        listener: (context, state) {
          if (state is KeyCreationStateSuccess) {
            if (context.router.current.name == NewSeedRouterRoute.name) {
              context.router.navigate(const SettingsRouterRoute());
            }
          }
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: UnfocusingGestureDetector(
            child: Scaffold(
              appBar: const CustomAppBar(),
              body: body(),
            ),
          ),
        ),
      );

  Widget body() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
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
            if (context.router.current.name != NewSeedRouterRoute.name) biometryCheckbox(),
          ],
        ),
      );

  void onChanged() {
    formKey.currentState?.validate();

    String? text;

    if (!isLength(passwordController.text, 8)) {
      text = 'Password must be at least 8 symbols';
    } else if (passwordController.text != repeatController.text) {
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
        autocorrect: false,
        enableSuggestions: false,
        obscureText: true,
        textInputAction: TextInputAction.next,
        hintText: LocaleKeys.password_creation_screen_password_hint.tr(),
        suffixIcon: SuffixIconButton(
          onPressed: () {
            passwordController.clear();
            Form.of(context)?.validate();
          },
          icon: Assets.images.iconCross.svg(),
        ),
        onSubmitted: (value) => FocusScope.of(context).nextFocus(),
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return null;
          }

          if (!isLength(value, 8)) {
            return value;
          }
        },
      );

  Widget repeatField() => CustomTextFormField(
        name: 'repeat',
        controller: repeatController,
        autocorrect: false,
        enableSuggestions: false,
        obscureText: true,
        textInputAction: TextInputAction.done,
        hintText: LocaleKeys.password_creation_screen_password_confirmation.tr(),
        suffixIcon: SuffixIconButton(
          onPressed: () {
            repeatController.clear();
            Form.of(context)?.validate();
          },
          icon: Assets.images.iconCross.svg(),
        ),
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return null;
          }

          if (passwordController.text != value) {
            return value;
          }
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

  Widget biometryCheckbox() => BlocBuilder<BiometryInfoBloc, BiometryInfoState>(
        bloc: context.watch<BiometryInfoBloc>(),
        builder: (context, state) {
          if (!state.isAvailable) {
            return const SizedBox();
          }

          return Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  CustomCheckbox(
                    value: state.isEnabled,
                    onChanged: (value) {
                      context.read<BiometryInfoBloc>().add(BiometryInfoEvent.setStatus(
                            localizedReason: 'Please authenticate to interact with wallet',
                            isEnabled: !state.isEnabled,
                          ));
                    },
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
          onPressed: value != null
              ? null
              : () {
                  final password = passwordController.text;

                  bloc.add(KeyCreationEvent.create(
                    name: widget.seedName,
                    phrase: widget.phrase,
                    password: password,
                  ));
                },
          text: LocaleKeys.actions_confirm.tr(),
        ),
      );
}
