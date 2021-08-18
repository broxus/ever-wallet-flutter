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

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WelcomeScaffold(
        allowIosBackSwipe: false,
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
            CrystalTextField(
              controller: nameController,
              hintText: LocaleKeys.new_seed_name_hint.tr(),
              keyboardType: TextInputType.text,
              autofocus: true,
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
              child: CrystalButton(
                text: widget.action.describe(),
                onTap: () => onConfirm(widget.action),
              ),
            ),
          );
        },
      );

  void onConfirm(CreationActions value) {
    switch (value) {
      case CreationActions.create:
        context.router.push(SeedPhraseSaveScreenRoute(seedName: nameController.text));
        break;
      case CreationActions.import:
        context.router.push(SeedPhraseImportScreenRoute(seedName: nameController.text));
        break;
    }
  }
}
