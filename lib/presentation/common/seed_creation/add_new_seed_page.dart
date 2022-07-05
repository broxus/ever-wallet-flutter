import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tuple/tuple.dart';

import '../../router.gr.dart';
import '../widgets/crystal_title.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/custom_dropdown_button.dart';
import '../widgets/custom_elevated_button.dart';

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
              onPressed: () => context.router.pop(),
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
                    const SizedBox(height: 8),
                    title(),
                    const SizedBox(height: 32),
                    dropdownButton(),
                    const SizedBox(height: 16),
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

  Widget submitButton() => PrimaryElevatedButton(
        onPressed: () => context.router.push(
          SeedNameRoute(
            onSubmit: (String? name) {
              optionNotifier.value == _CreationActions.create
                  ? context.router.push(
                      SeedPhraseSaveRoute(
                        seedName: name,
                      ),
                    )
                  : context.router.push(
                      SeedPhraseImportRoute(
                        seedName: name,
                        isLegacy: optionNotifier.value == _CreationActions.importLegacy,
                      ),
                    );
            },
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
