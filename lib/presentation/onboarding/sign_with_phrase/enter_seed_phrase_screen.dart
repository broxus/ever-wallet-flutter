import 'package:flutter/material.dart';

import '../../common/general/button/primary_button.dart';
import '../../common/general/default_appbar.dart';
import '../../common/general/field/bordered_input.dart';
import '../../util/extensions/context_extensions.dart';
import '../../util/extensions/iterable_extensions.dart';
import '../../util/theme_styles.dart';
import '../general_screens/create_password.dart';
import '../widgets/onboarding_background.dart';
import 'widgets/tabbar.dart';

class EnterSeedPhraseRoute extends MaterialPageRoute<void> {
  EnterSeedPhraseRoute(String phraseName)
      : super(builder: (_) => EnterSeedPhraseScreen(phraseName: phraseName));
}

class EnterSeedPhraseScreen extends StatefulWidget {
  final String phraseName;

  const EnterSeedPhraseScreen({Key? key, required this.phraseName}) : super(key: key);

  @override
  State<EnterSeedPhraseScreen> createState() => _EnterSeedPhraseScreenState();
}

class _EnterSeedPhraseScreenState extends State<EnterSeedPhraseScreen> {
  final formKey = GlobalKey<FormState>();
  final controllers = List.generate(24, (_) => TextEditingController());
  final focuses = List.generate(24, (_) => FocusNode());
  final values = const <int>[12, 24];
  late ValueNotifier<int> valuesNotifier = ValueNotifier<int>(values.first);

  @override
  void dispose() {
    controllers.forEach((c) => c.dispose());
    focuses.forEach((f) => f.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localization;
    final themeStyle = context.themeStyle;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return OnboardingBackground(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          appBar: const DefaultAppBar(),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: ValueListenableBuilder<int>(
                        valueListenable: valuesNotifier,
                        builder: (_, value, __) {
                          final activeControllers = controllers.take(value).toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localization.enter_seed_phrase,
                                style: themeStyle.styles.appbarStyle,
                              ),
                              const SizedBox(height: 28),
                              EWTabBar<int>(
                                values: values,
                                selectedValue: value,
                                onChanged: (v) {
                                  formKey.currentState?.reset();
                                  valuesNotifier.value = v;
                                },
                                builder: (_, v, isActive) {
                                  return Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      // TODO: replace word
                                      '$v words',
                                      style: themeStyle.styles.basicStyle.copyWith(
                                        color: isActive
                                            ? null
                                            : themeStyle.colors.textSecondaryTextButtonColor,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: activeControllers
                                          .getRange(0, value ~/ 2)
                                          .mapIndex(
                                            (c, index) => _inputBuild(
                                              c,
                                              focuses[index],
                                              index + 1,
                                              themeStyle,
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      children:
                                          activeControllers.getRange(value ~/ 2, value).mapIndex(
                                        (c, index) {
                                          final i = index + value ~/ 2;
                                          return _inputBuild(c, focuses[i], i + 1, themeStyle);
                                        },
                                      ).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: bottomPadding < kPrimaryButtonHeight
                      ? 0
                      : bottomPadding - kPrimaryButtonHeight,
                ),
                PrimaryButton(
                  text: localization.confirm,
                  onPressed: _confirmAction,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputBuild(
    TextEditingController controller,
    FocusNode focus,
    int index,
    ThemeStyle themeStyle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: BorderedInput(
        key: Key('SeedPhrase_$index'),
        controller: controller,
        focusNode: focus,
        textInputAction:
            index == valuesNotifier.value ? TextInputAction.done : TextInputAction.next,
        validator: (v) {
          if (controller.text.isNotEmpty) {
            return null;
          }
          return '';
        },
        onSubmitted: (_) {
          if (index == valuesNotifier.value) {
            _confirmAction();
          } else {
            // index starts with 1 so here it means we take next one
            focuses[index].requestFocus();
          }
        },
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

  void _confirmAction() {
    if (formKey.currentState?.validate() ?? false) {
      final phrase = controllers.take(valuesNotifier.value).map((e) => e.text).toList();
      Navigator.of(context).push(CreatePasswordRoute(phrase, widget.phraseName));
    }
  }
}
