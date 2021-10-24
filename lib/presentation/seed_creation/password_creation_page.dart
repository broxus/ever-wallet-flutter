import 'dart:math' as math;

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:validators/validators.dart';

import '../../domain/blocs/biometry/biometry_info_bloc.dart';
import '../../domain/blocs/key/key_creation_bloc.dart';
import '../../injection.dart';
import '../design/design.dart';
import '../design/utils.dart';
import '../design/widget/crystal_scaffold.dart';
import '../router.gr.dart';

class PasswordCreationPage extends StatefulWidget {
  final List<String> phrase;
  final String? seedName;

  const PasswordCreationPage({
    Key? key,
    required this.phrase,
    this.seedName,
  }) : super(key: key);

  @override
  _PasswordCreationPageState createState() => _PasswordCreationPageState();
}

class _PasswordCreationPageState extends State<PasswordCreationPage> {
  final formKey = GlobalKey<FormState>();
  final scrollController = ScrollController();
  final passwordController = TextEditingController();
  final repeatController = TextEditingController();
  final validationNotifier = ValueNotifier<String?>('');

  @override
  void dispose() {
    scrollController.dispose();
    passwordController.dispose();
    repeatController.dispose();
    validationNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CrystalScaffold(
        onScaffoldTap: FocusScope.of(context).unfocus,
        headline: LocaleKeys.password_creation_screen_creation_title.tr(),
        body: buildBody(),
      );

  Widget buildBody() => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Stack(
          children: [
            buildTextFieldList(),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: buildActions(),
            ),
          ],
        ),
      );

  Widget buildDescription() => Text(
        LocaleKeys.password_creation_screen_creation_description.tr(),
        textAlign: TextAlign.start,
        style: const TextStyle(
          fontSize: 16,
          color: CrystalColor.fontDark,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
      );

  Widget buildTextFieldList() => Padding(
        padding: context.keyboardInsets,
        child: Form(
          key: formKey,
          onChanged: () {
            formKey.currentState?.validate();
          },
          child: FadingEdgeScrollView.fromScrollView(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              cacheExtent: context.screenSize.height,
              shrinkWrap: true,
              controller: scrollController,
              padding: const EdgeInsets.only(
                top: 8,
                bottom: CrystalButton.kHeight + 12,
              ),
              children: [
                buildDescription(),
                const CrystalDivider(height: 20),
                buildTextField(
                  controller: passwordController,
                  hint: LocaleKeys.password_creation_screen_password_hint.tr(),
                  inputAction: TextInputAction.next,
                ),
                const CrystalDivider(height: 20),
                buildTextField(
                  controller: repeatController,
                  hint: LocaleKeys.password_creation_screen_password_confirmation.tr(),
                  inputAction: TextInputAction.done,
                ),
                buildValidationText(),
                if (context.router.current.parent?.name != NewSeedRouterRoute.name) ...[
                  const CrystalDivider(height: 10),
                  buildBiometryCheck(),
                  const CrystalDivider(height: 20),
                ],
              ],
            ),
          ),
        ),
      );

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required TextInputAction inputAction,
  }) =>
      CrystalTextFormField(
        controller: controller,
        hintText: hint,
        keyboardType: TextInputType.text,
        obscureText: true,
        scrollPadding: EdgeInsets.only(
          bottom: context.keyboardInsets.bottom + 24 + CrystalButton.kHeight,
        ),
        validator: (value) {
          if (value == null) {
            return null;
          }

          String? text;

          if (passwordController.text != repeatController.text) {
            text = "Passwords must match";
          }

          if (!isLength(value, 8)) {
            text = "Password must be at least 8 symbols";
          }

          validationNotifier.value = text;

          return text;
        },
        inputAction: inputAction,
      );

  Widget buildValidationText() => ValueListenableBuilder<String?>(
        valueListenable: validationNotifier,
        builder: (context, value, child) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: value != null
              ? Container(
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
                )
              : const SizedBox(),
        ),
      );

  Widget buildBiometryCheck() => BlocBuilder<BiometryInfoBloc, BiometryInfoState>(
        bloc: context.watch<BiometryInfoBloc>(),
        builder: (context, state) {
          if (!state.isAvailable) {
            return const SizedBox();
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.read<BiometryInfoBloc>().add(BiometryInfoEvent.setStatus(!state.isEnabled)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CrystalDivider(width: 16),
                  CrystalCheckbox(
                    value: state.isEnabled,
                  ),
                  const SizedBox(width: 17),
                  Expanded(
                    child: Text(
                      LocaleKeys.biometry_checkbox.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        letterSpacing: 0.75,
                        color: CrystalColor.fontDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

  Widget buildActions() => AnimatedPadding(
        curve: Curves.decelerate,
        duration: kThemeAnimationDuration,
        padding: EdgeInsets.only(
          bottom: math.max(getKeyboardInsetsBottom(context), 0) + 12,
        ),
        child: AnimatedAppearance(
          delay: kThemeAnimationDuration,
          duration: const Duration(milliseconds: 350),
          child: ValueListenableBuilder<String?>(
            valueListenable: validationNotifier,
            builder: (context, value, child) => CrystalButton(
              enabled: value == null,
              text: LocaleKeys.password_creation_screen_creation_action.tr(),
              onTap: () => onConfirm(passwordController.text),
            ),
          ),
        ),
      );

  Future<void> onConfirm(String password) async {
    FocusScope.of(context).unfocus();

    final bloc = getIt.get<KeyCreationBloc>();

    bloc.add(KeyCreationEvent.create(
      name: widget.seedName,
      phrase: widget.phrase,
      password: password,
    ));
    if (context.router.current.parent?.name == NewSeedRouterRoute.name) {
      context.router.navigate(const SettingsRouterRoute());
    }

    await bloc.stream.first;

    bloc.close();
  }
}
