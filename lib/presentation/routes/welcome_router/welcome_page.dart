import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../design/design.dart';
import '../../design/widgets/crystal_subtitle.dart';
import '../../design/widgets/crystal_title.dart';
import '../../design/widgets/custom_elevated_button.dart';
import '../../design/widgets/custom_outlined_button.dart';
import '../router.gr.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                bottom: MediaQuery.of(context).size.longestSide / 2.5,
                child: const ColoredBox(
                  color: CrystalColor.accentBackground,
                ),
              ),
              body(context),
            ],
          ),
        ),
      );

  Widget body(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),
                    title(),
                    const SizedBox(height: 16),
                    subtitle(),
                    const SizedBox(height: 72),
                    image(),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    createNewButton(context),
                    const SizedBox(height: 16),
                    signInButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget title() => CrystalTitle(
        text: LocaleKeys.welcome_screen_title.tr(),
      );

  Widget subtitle() => CrystalSubtitle(
        text: LocaleKeys.welcome_screen_subtitle.tr(),
      );

  Widget image() => Align(
        alignment: Alignment.centerLeft,
        child: Assets.images.welcomeImage.svg(),
      );

  Widget createNewButton(BuildContext context) => CustomElevatedButton(
        onPressed: () => context.router.push(
          DecentralizationPolicyRoute(
            onPressed: () => context.router.push(
              SeedNameRoute(
                onSubmit: (String? name) => context.router.push(
                  SeedPhraseSaveRoute(
                    seedName: name,
                  ),
                ),
              ),
            ),
          ),
        ),
        text: LocaleKeys.welcome_screen_action_create.tr(),
      );

  Widget signInButton(BuildContext context) => CustomOutlinedButton(
        onPressed: () => context.router.push(
          DecentralizationPolicyRoute(
            onPressed: () => context.router.push(
              SeedPhraseTypeRoute(
                onSelected: (MnemonicType mnemonicType) => context.router.push(
                  SeedNameRoute(
                    onSubmit: (String? name) => context.router.push(
                      SeedPhraseImportRoute(
                        seedName: name,
                        isLegacy: mnemonicType == const MnemonicType.legacy(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        text: LocaleKeys.welcome_screen_action_sign_in.tr(),
      );
}
