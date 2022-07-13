import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/widgets/crystal_title.dart';
import 'package:ever_wallet/application/common/widgets/custom_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class SeedPhraseTypePage extends StatelessWidget {
  final void Function(MnemonicType mnemonicType) onSelected;

  const SeedPhraseTypePage({
    Key? key,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          appBar: AppBar(
            leading: const CustomBackButton(),
          ),
          body: body(context),
        ),
      );

  Widget body(BuildContext context) => SafeArea(
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
                    title(context),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    seedButton(
                      context: context,
                      title: AppLocalizations.of(context)!.regular_seed,
                      subtitle: AppLocalizations.of(context)!.regular_seed_description,
                      mnemonicType: kDefaultMnemonicType,
                    ),
                    const SizedBox(height: 16),
                    seedButton(
                      context: context,
                      title: AppLocalizations.of(context)!.legacy_seed,
                      subtitle: AppLocalizations.of(context)!.legacy_seed_description,
                      mnemonicType: const MnemonicType.legacy(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget title(BuildContext context) => CrystalTitle(
        text: AppLocalizations.of(context)!.seed_phrase_type_description,
      );

  Widget seedButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required MnemonicType mnemonicType,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            PrimaryElevatedButton(
              onPressed: () => onSelected(mnemonicType),
              text: AppLocalizations.of(context)!.select,
            ),
          ],
        ),
      );
}
