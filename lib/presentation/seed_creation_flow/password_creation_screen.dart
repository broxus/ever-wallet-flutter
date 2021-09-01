import 'dart:math' as math;

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/blocs/biometry/biometry_info_bloc.dart';
import '../../domain/blocs/key/key_creation_bloc.dart';
import '../../injection.dart';
import '../design/design.dart';
import '../design/utils.dart';
import '../welcome/widget/welcome_scaffold.dart';

class PasswordCreationScreen extends StatefulWidget {
  final List<String> phrase;
  final String seedName;

  const PasswordCreationScreen({
    Key? key,
    required this.phrase,
    required this.seedName,
  }) : super(key: key);

  @override
  _PasswordCreationScreenState createState() => _PasswordCreationScreenState();
}

class _PasswordCreationScreenState extends State<PasswordCreationScreen> {
  final scrollController = ScrollController();
  final passwordController = TextEditingController();
  final repeatController = TextEditingController();
  final bloc = getIt.get<KeyCreationBloc>();

  @override
  void dispose() {
    scrollController.dispose();
    passwordController.dispose();
    repeatController.dispose();
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WelcomeScaffold(
        onScaffoldTap: FocusScope.of(context).unfocus,
        headline: LocaleKeys.password_creation_screen_creation_title.tr(),
        body: buildBody(),
      );

  Widget buildBody() => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
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
          fontSize: 16.0,
          color: CrystalColor.fontDark,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
      );

  Widget buildTextFieldList() => Padding(
        padding: context.keyboardInsets,
        child: FadingEdgeScrollView.fromScrollView(
          child: ListView(
            cacheExtent: context.screenSize.height,
            shrinkWrap: true,
            controller: scrollController,
            padding: const EdgeInsets.only(
              top: 8.0,
              bottom: CrystalButton.kHeight + 12.0,
            ),
            children: [
              buildDescription(),
              const CrystalDivider(height: 20.0),
              buildTextField(
                controller: passwordController,
                hint: LocaleKeys.password_creation_screen_password_hint.tr(),
              ),
              const CrystalDivider(height: 20.0),
              buildTextField(
                controller: repeatController,
                hint: LocaleKeys.password_creation_screen_password_confirmation.tr(),
              ),
              if (context.router.root.current.name != MainFlowRoute.name) ...[
                const CrystalDivider(height: 10),
                buildBiometryCheck(),
                const CrystalDivider(height: 20),
              ],
            ],
          ),
        ),
      );

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
  }) =>
      CrystalTextField(
        controller: controller,
        hintText: hint,
        keyboardType: TextInputType.text,
        obscureText: true,
        scrollPadding: EdgeInsets.only(
          bottom: context.keyboardInsets.bottom + 24 + CrystalButton.kHeight,
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
          onTap: () =>
              context.read<BiometryInfoBloc>().add(BiometryInfoEvent.setBiometryStatus(isEnabled: !state.isEnabled)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CrystalDivider(width: 16.0),
                CrystalCheckbox(
                  value: state.isEnabled,
                ),
                const SizedBox(width: 17),
                Expanded(
                  child: Text(
                    LocaleKeys.biometry_checkbox.tr(),
                    style: const TextStyle(
                      fontSize: 14.0,
                      height: 20.0 / 14.0,
                      letterSpacing: 0.75,
                      color: CrystalColor.fontDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });

  Widget buildActions() => AnimatedPadding(
        curve: Curves.decelerate,
        duration: kThemeAnimationDuration,
        padding: EdgeInsets.only(
          bottom: math.max(
                getKeyboardInsetsBottom(context),
                0,
              ) +
              12,
        ),
        child: AnimatedAppearance(
          delay: kThemeAnimationDuration,
          duration: const Duration(milliseconds: 350),
          child: AnimatedBuilder(
            animation: Listenable.merge([passwordController, repeatController]),
            builder: (context, _) {
              final pass = passwordController.text.trim();
              return CrystalButton(
                enabled: pass == repeatController.text.trim(),
                text: LocaleKeys.password_creation_screen_creation_action.tr(),
                onTap: () => onConfirm(pass),
              );
            },
          ),
        ),
      );

  void onConfirm(String password) {
    FocusScope.of(context).unfocus();
    bloc.add(KeyCreationEvent.createKey(
      name: widget.seedName,
      phrase: widget.phrase,
      password: password,
    ));
    if (context.router.root.current.name == MainFlowRoute.name) {
      context.router.navigate(const SettingsFlowRoute());
    }
  }
}
