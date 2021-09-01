import 'package:flutter/material.dart';

import '../design/design.dart';
import 'widget/welcome_scaffold.dart';

class NameSeedScreen extends StatefulWidget {
  final CreationActions action;

  const NameSeedScreen({required this.action});

  @override
  _NameSeedScreenState createState() => _NameSeedScreenState();
}

class _NameSeedScreenState extends State<NameSeedScreen> {
  final nameController = TextEditingController();
  final selectedSeedType = ValueNotifier<SeedType>(SeedType.labs);

  @override
  void dispose() {
    selectedSeedType.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WelcomeScaffold(
        onScaffoldTap: FocusScope.of(context).unfocus,
        headline: LocaleKeys.new_seed_name_headline.tr(),
        body: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: buildBody(),
        ),
      );

  Widget buildBody() => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CrystalTextField(
                  controller: nameController,
                  hintText: LocaleKeys.new_seed_name_hint.tr(),
                  keyboardType: TextInputType.text,
                ),
                const CrystalDivider(height: 24.0),
                if (widget.action != CreationActions.create)
                  ValueListenableBuilder<SeedType>(
                    valueListenable: selectedSeedType,
                    builder: (context, value, child) => CrystalValueSelector<SeedType>(
                      selectedValue: value,
                      options: SeedType.values,
                      nameOfOption: (o) => o.describe(),
                      onSelect: (contract) => selectedSeedType.value = contract,
                    ),
                  ),
                const CrystalDivider(height: 16),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: buildActions(),
            ),
          ],
        ),
      );

  Widget buildActions() => ValueListenableBuilder<TextEditingValue>(
        valueListenable: nameController,
        builder: (BuildContext context, TextEditingValue value, Widget? child) {
          final double bottomPadding = context.keyboardInsets.bottom + 12;
          return AnimatedPadding(
            curve: Curves.decelerate,
            duration: kThemeAnimationDuration,
            padding: EdgeInsets.only(
              bottom: bottomPadding,
            ),
            child: AnimatedAppearance(
              showing: value.text.isNotEmpty,
              duration: const Duration(milliseconds: 350),
              child: widget.action != CreationActions.create
                  ? ValueListenableBuilder<SeedType>(
                      valueListenable: selectedSeedType,
                      builder: (context, value, child) => CrystalButton(
                        text: value.describe(),
                        onTap: () => onImportConfirm(value),
                      ),
                    )
                  : CrystalButton(
                      text: widget.action.describe(),
                      onTap: () => onCreateConfirm(widget.action),
                    ),
            ),
          );
        },
      );

  void onCreateConfirm(CreationActions value) {
    switch (value) {
      case CreationActions.create:
        context.router.push(SeedPhraseSaveScreenRoute(seedName: nameController.text));
        break;
      default:
        break;
    }
  }

  void onImportConfirm(SeedType value) {
    switch (value) {
      case SeedType.labs:
        context.router.push(SeedPhraseImportScreenRoute(
          seedName: nameController.text,
          isLegacy: false,
        ));
        break;
      case SeedType.legacy:
        context.router.push(SeedPhraseImportScreenRoute(
          seedName: nameController.text,
          isLegacy: true,
        ));
        break;
    }
  }
}

enum SeedType {
  labs,
  legacy,
}

extension on SeedType {
  String describe() {
    switch (this) {
      case SeedType.labs:
        return 'Import seed';
      case SeedType.legacy:
        return 'Import legacy seed';
    }
  }
}
