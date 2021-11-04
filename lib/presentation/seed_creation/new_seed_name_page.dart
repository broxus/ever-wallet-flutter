import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../design/design.dart';
import '../design/utils.dart';
import '../design/widget/crystal_scaffold.dart';
import '../router.gr.dart';

class NewSeedNamePage extends StatefulWidget {
  @override
  _NewSeedNamePageState createState() => _NewSeedNamePageState();
}

class _NewSeedNamePageState extends State<NewSeedNamePage> {
  final scrollController = ScrollController();
  final nameController = TextEditingController();
  final creationValueNotifier = ValueNotifier<CreationActions>(CreationActions.create);

  String? get name => nameController.text.isNotEmpty ? nameController.text : null;

  @override
  void dispose() {
    scrollController.dispose();
    nameController.dispose();
    creationValueNotifier.dispose();
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
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
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
                ValueListenableBuilder<CreationActions>(
                  valueListenable: creationValueNotifier,
                  builder: (context, value, child) => CrystalValueSelector<CreationActions>(
                    selectedValue: value,
                    options: CreationActions.values,
                    nameOfOption: (o) => o.describe(),
                    onSelect: (v) => creationValueNotifier.value = v,
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
          final double bottomPadding = math.max(getKeyboardInsetsBottom(context), 0) + 12;

          return AnimatedPadding(
            curve: Curves.decelerate,
            duration: kThemeAnimationDuration,
            padding: EdgeInsets.only(
              bottom: bottomPadding,
            ),
            child: ValueListenableBuilder<CreationActions>(
              valueListenable: creationValueNotifier,
              builder: (context, value, child) => CrystalButton(
                text: value.describe(),
                onTap: () => onConfirm(value),
              ),
            ),
          );
        },
      );

  void onConfirm(CreationActions value) {
    switch (value) {
      case CreationActions.create:
        context.router.push(SeedPhraseSaveRoute(seedName: name));
        break;
      case CreationActions.import:
        context.router.push(SeedPhraseImportRoute(
          seedName: name,
          isLegacy: false,
        ));
        break;
      case CreationActions.importLegacy:
        context.router.push(SeedPhraseImportRoute(
          seedName: name,
          isLegacy: true,
        ));
        break;
    }
  }
}
