import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../generated/assets.gen.dart';
import '../../generated/codegen_loader.g.dart';
import '../common/theme.dart';
import '../common/widgets/crystal_subtitle.dart';
import '../common/widgets/crystal_title.dart';
import '../common/widgets/custom_elevated_button.dart';
import '../common/widgets/custom_outlined_button.dart';
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
        text: LocaleKeys.welcome_title.tr(),
      );

  Widget subtitle() => CrystalSubtitle(
        text: LocaleKeys.welcome_subtitle.tr(),
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
        text: LocaleKeys.create_new_wallet.tr(),
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
        text: LocaleKeys.sign_in.tr(),
      );
}
