import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';

import '../../../design/design.dart';
import '../../../design/widgets/crystal_title.dart';
import '../../../design/widgets/custom_back_button.dart';
import '../../../design/widgets/custom_dropdown_button.dart';
import '../../../design/widgets/custom_elevated_button.dart';
import '../../router.gr.dart';

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

  Widget title() => const CrystalTitle(
        text: 'Create new seed or add existing',
      );

  Widget dropdownButton() => ValueListenableBuilder<_CreationActions>(
        valueListenable: optionNotifier,
        builder: (context, value, child) => CustomDropdownButton<_CreationActions>(
          items: _CreationActions.values.map((e) => Tuple2(e, e.describe())).toList(),
          value: value,
          onChanged: (value) {
            if (value != null) {
              optionNotifier.value = value;
            }
          },
        ),
      );

  Widget submitButton() => CustomElevatedButton(
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
        text: 'Next',
      );
}

enum _CreationActions {
  create,
  import,
  importLegacy,
}

extension on _CreationActions {
  String describe() {
    switch (this) {
      case _CreationActions.create:
        return LocaleKeys.new_seed_name_actions_create.tr();
      case _CreationActions.import:
        return LocaleKeys.new_seed_name_actions_import.tr();
      case _CreationActions.importLegacy:
        return LocaleKeys.new_seed_name_actions_import_legacy.tr();
    }
  }
}
