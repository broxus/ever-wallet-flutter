import 'package:flutter/material.dart';

import '../design/design.dart';
import '../design/widget/crystal_scaffold.dart';
import '../router.gr.dart';

enum _SeedType {
  labs,
  legacy,
}

extension on _SeedType {
  String describe() {
    switch (this) {
      case _SeedType.labs:
        return 'Import seed (12 words)';
      case _SeedType.legacy:
        return 'Import legacy seed (24 words)';
    }
  }
}

class SeedNamePage extends StatefulWidget {
  final CreationActions action;

  const SeedNamePage({
    Key? key,
    required this.action,
  }) : super(key: key);

  @override
  _SeedNamePageState createState() => _SeedNamePageState();
}

class _SeedNamePageState extends State<SeedNamePage> {
  final nameController = TextEditingController();
  final selectedSeedType = ValueNotifier<_SeedType>(_SeedType.labs);

  String? get name => nameController.text.isNotEmpty ? nameController.text : null;

  @override
  void dispose() {
    selectedSeedType.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CrystalScaffold(
        onScaffoldTap: FocusScope.of(context).unfocus,
        headline: LocaleKeys.new_seed_name_headline.tr(),
        body: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: buildBody(),
        ),
      );

  Widget buildBody() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CrystalTextFormField(
                  controller: nameController,
                  hintText: LocaleKeys.new_seed_name_hint.tr(),
                  keyboardType: TextInputType.text,
                ),
                const CrystalDivider(height: 24),
                if (widget.action != CreationActions.create)
                  ValueListenableBuilder<_SeedType>(
                    valueListenable: selectedSeedType,
                    builder: (context, value, child) => CrystalValueSelector<_SeedType>(
                      selectedValue: value,
                      options: _SeedType.values,
                      nameOfOption: (o) => o.describe(),
                      onSelect: (seedType) => selectedSeedType.value = seedType,
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

  Widget buildActions() => AnimatedPadding(
        curve: Curves.decelerate,
        duration: kThemeAnimationDuration,
        padding: EdgeInsets.only(
          bottom: context.keyboardInsets.bottom + 12,
        ),
        child: widget.action != CreationActions.create
            ? ValueListenableBuilder<_SeedType>(
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
      );

  void onCreateConfirm(CreationActions value) {
    switch (value) {
      case CreationActions.create:
        context.router.push(SeedPhraseSaveRoute(seedName: name));
        break;
      default:
        break;
    }
  }

  void onImportConfirm(_SeedType value) {
    switch (value) {
      case _SeedType.labs:
        context.router.push(SeedPhraseImportRoute(
          seedName: name,
          isLegacy: false,
        ));
        break;
      case _SeedType.legacy:
        context.router.push(SeedPhraseImportRoute(
          seedName: name,
          isLegacy: true,
        ));
        break;
    }
  }
}
