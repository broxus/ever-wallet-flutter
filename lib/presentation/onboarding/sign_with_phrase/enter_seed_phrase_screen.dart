import 'package:flutter/material.dart';

import '../../common/general/button/primary_button.dart';
import '../../common/general/default_appbar.dart';
import '../../common/general/field/bordered_input.dart';
import '../../util/extensions/context_extensions.dart';
import '../../util/extensions/iterable_extensions.dart';
import '../../util/theme_styles.dart';
import '../widgets/onboarding_background.dart';
import 'widgets/tabbar.dart';

class EnterSeedPhraseRoute extends MaterialPageRoute<void> {
  EnterSeedPhraseRoute() : super(builder: (_) => const EnterSeedPhraseScreen());
}

class EnterSeedPhraseScreen extends StatefulWidget {
  const EnterSeedPhraseScreen({Key? key}) : super(key: key);

  @override
  State<EnterSeedPhraseScreen> createState() => _EnterSeedPhraseScreenState();
}

class _EnterSeedPhraseScreenState extends State<EnterSeedPhraseScreen> {
  final controllers = List.generate(24, (_) => TextEditingController());
  int value = 12;

  @override
  Widget build(BuildContext context) {
    final localization = context.localization;
    final themeStyle = context.themeStyle;
    final activeControllers = controllers.take(value).toList();

    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const DefaultAppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              Text(localization.enter_seed_phrase, style: themeStyle.styles.appbarStyle),
              const SizedBox(height: 28),
              EWTabBar<int>(
                values: const [12, 24],
                selectedValue: value,
                onChanged: (v) => setState(() => value = v),
                builder: (_, v, isActive) {
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      // TODO: replace word
                      '$v words',
                      style: themeStyle.styles.basicStyle.copyWith(
                        color: isActive ? null : themeStyle.colors.textSecondaryTextButtonColor,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: activeControllers
                              .getRange(0, value ~/ 2)
                              .mapIndex((c, index) => _inputBuild(c, index + 1, themeStyle))
                              .toList(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: activeControllers
                              .getRange(value ~/ 2, value)
                              .mapIndex(
                                (c, index) => _inputBuild(c, index + value ~/ 2 + 1, themeStyle),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PrimaryButton(
                text: localization.confirm,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputBuild(
    TextEditingController controller,
    int index,
    ThemeStyle themeStyle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: BorderedInput(
        key: Key('SeedPhrase_$index'),
        controller: controller,
        prefix: Padding(
          padding: const EdgeInsets.only(left: 16, top: 11),
          child: Text(
            '$index.',
            style: themeStyle.styles.basicStyle.copyWith(
              color: themeStyle.colors.textSecondaryTextButtonColor,
            ),
          ),
        ),
      ),
    );
  }
}
