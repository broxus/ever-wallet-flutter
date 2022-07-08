import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../common/general/button/primary_button.dart';
import '../../../../../../common/general/button/text_button.dart';
import '../../../../../../common/general/field/seed_phrase_input.dart';
import '../../../../../../util/colors.dart';
import '../../../../../../util/extensions/context_extensions.dart';
import '../../../../../../util/extensions/iterable_extensions.dart';
import '../../../../../../util/theme_styles.dart';

class AddNewSeedImportWidget extends StatefulWidget {
  const AddNewSeedImportWidget({
    Key? key,
    required this.backAction,
    required this.savedPhrase,
    required this.onPhraseEntered,
  }) : super(key: key);

  final VoidCallback backAction;
  final List<String>? savedPhrase;
  final ValueChanged<List<String>> onPhraseEntered;

  @override
  State<AddNewSeedImportWidget> createState() => _AddNewSeedImportWidgetState();
}

class _AddNewSeedImportWidgetState extends State<AddNewSeedImportWidget> {
  final formKey = GlobalKey<FormState>();
  late List<TextEditingController> controllers;
  late List<FocusNode> focuses;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(
      12,
      (index) => TextEditingController(text: widget.savedPhrase?[index] ?? ''),
    );
    focuses = List.generate(12, (_) => FocusNode());
  }

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: TextPrimaryButton.appBar(
                onPressed: widget.backAction,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back_ios, color: ColorsRes.darkBlue, size: 20),
                      Text(
                        // TODO: replace text
                        'Back',
                        style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.darkBlue),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Text(
              localization.enter_seed_phrase,
              style: themeStyle.styles.basicStyle.copyWith(
                fontWeight: FontWeight.w700,
                color: ColorsRes.text,
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 30),
        _buildPhrasesList(localization, themeStyle),
        SizedBox(
          height: bottomPadding < kPrimaryButtonHeight ? 0 : bottomPadding - kPrimaryButtonHeight,
        ),
        PrimaryButton(
          text: localization.confirm,
          onPressed: _confirmAction,
        ),
      ],
    );
  }

  Widget _buildPhrasesList(AppLocalizations localization, ThemeStyle themeStyle) {
    final length = controllers.length;
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: controllers
                    .getRange(0, length ~/ 2)
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
                mainAxisSize: MainAxisSize.min,
                children: controllers.getRange(length ~/ 2, length).mapIndex(
                  (c, index) {
                    final i = index + length ~/ 2;
                    return _inputBuild(c, focuses[i], i + 1, themeStyle);
                  },
                ).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// [index] start with 1
  Widget _inputBuild(
    TextEditingController controller,
    FocusNode focus,
    int index,
    ThemeStyle themeStyle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SeedPhraseInput(
        controller: controller,
        focus: focus,
        prefixText: '$index.',
        requestNextField: () => focuses[index].requestFocus(),
        textInputAction: index == controllers.length ? TextInputAction.done : TextInputAction.next,
        confirmAction: _confirmAction,
      ),
    );
  }

  void _confirmAction() {
    if (formKey.currentState?.validate() ?? false) {
      final phrase = controllers.map((e) => e.text).toList();
      widget.onPhraseEntered(phrase);
    }
  }
}
