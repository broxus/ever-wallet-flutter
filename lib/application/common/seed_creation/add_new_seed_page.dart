import 'package:ever_wallet/application/common/seed_creation/seed_name_screen.dart';
import 'package:ever_wallet/application/common/seed_creation/seed_phrase_import_screen.dart';
import 'package:ever_wallet/application/common/seed_creation/seed_phrase_save_screen.dart';
import 'package:ever_wallet/application/common/widgets/crystal_title.dart';
import 'package:ever_wallet/application/common/widgets/custom_back_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_dropdown_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:tuple/tuple.dart';

class AddNewSeedPage extends StatefulWidget {
  const AddNewSeedPage({
    Key? key,
  }) : super(key: key);

  @override
  State<AddNewSeedPage> createState() => _AddNewSeedPageState();
}

class _AddNewSeedPageState extends State<AddNewSeedPage> {
  final optionNotifier = ValueNotifier<_CreationActions>(_CreationActions.create);

  @override
  void dispose() {
    optionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          appBar: AppBar(
            leading: CustomBackButton(
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: body(),
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
                    const Gap(32),
                    dropdownButton(),
                    const Gap(16),
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
        text: AppLocalizations.of(context)!.add_new_seed_phrase_description,
      );

  Widget dropdownButton() => ValueListenableBuilder<_CreationActions>(
        valueListenable: optionNotifier,
        builder: (context, value, child) => CustomDropdownButton<_CreationActions>(
          items: _CreationActions.values.map((e) => Tuple2(e, e.describe(context))).toList(),
          value: value,
          onChanged: (value) {
            if (value != null) {
              optionNotifier.value = value;
            }
          },
        ),
      );

  Widget submitButton() => CustomElevatedButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => SeedNameScreen(
              onSubmit: (String? name) {
                optionNotifier.value == _CreationActions.create
                    ? Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => SeedPhraseSaveScreen(
                            seedName: name,
                          ),
                        ),
                      )
                    : Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => SeedPhraseImportScreen(
                            seedName: name,
                            isLegacy: optionNotifier.value == _CreationActions.importLegacy,
                          ),
                        ),
                      );
              },
            ),
          ),
        ),
        text: AppLocalizations.of(context)!.next,
      );
}

enum _CreationActions {
  create,
  import,
  importLegacy,
}

extension on _CreationActions {
  String describe(BuildContext context) {
    switch (this) {
      case _CreationActions.create:
        return AppLocalizations.of(context)!.create_seed;
      case _CreationActions.import:
        return AppLocalizations.of(context)!.import_seed;
      case _CreationActions.importLegacy:
        return AppLocalizations.of(context)!.import_legacy_seed;
    }
  }
}
