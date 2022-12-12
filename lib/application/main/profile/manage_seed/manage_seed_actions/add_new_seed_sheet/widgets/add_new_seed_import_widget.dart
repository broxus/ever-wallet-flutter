import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/general/button/primary_button.dart';
import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/general/button/text_button.dart';
import 'package:ever_wallet/application/common/general/field/seed_phrase_input.dart';
import 'package:ever_wallet/application/common/general/flushbar.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/extensions/iterable_extensions.dart';
import 'package:ever_wallet/application/util/theme_styles.dart';
import 'package:ever_wallet/application/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class AddNewSeedImportWidget extends StatefulWidget {
  const AddNewSeedImportWidget({
    super.key,
    required this.backAction,
    required this.savedPhrase,
    required this.onPhraseEntered,
    required this.isLegacy,
  });

  final VoidCallback backAction;
  final List<String>? savedPhrase;
  final ValueChanged<List<String>> onPhraseEntered;
  final bool isLegacy;

  @override
  State<AddNewSeedImportWidget> createState() => _AddNewSeedImportWidgetState();
}

class _AddNewSeedImportWidgetState extends State<AddNewSeedImportWidget> {
  final formKey = GlobalKey<FormState>();
  late List<TextEditingController> controllers;
  late List<FocusNode> focuses;

  /// Display paste only if there are no text(false) in fields else clear (true)
  final isClearButtonState = ValueNotifier<bool>(false);

  int get wordsCount => widget.isLegacy ? 24 : 12;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(
      wordsCount,
      (index) => TextEditingController(text: widget.savedPhrase?[index] ?? ''),
    );
    controllers.forEach(
      (c) => c.addListener(() {
        final hasText = controllers.any((controller) => controller.text.isNotEmpty);
        isClearButtonState.value = hasText;
      }),
    );
    controllers[0].addListener(() {
      /// Only for 1-st controller allow paste as button
      /// It's some bug but Input's paste removes spaces so check with length
      if (controllers[0].text.length > 15) {
        _pastePhrase();
      }
    });
    focuses = List.generate(wordsCount, (_) => FocusNode());
    focuses.forEach(
      (f) => f.addListener(() {
        if (f.hasFocus) {
          formKey.currentState?.reset();
        }
      }),
    );
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
            TextPrimaryButton.appBar(
              onPressed: widget.backAction,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back_ios, color: ColorsRes.darkBlue, size: 20),
                    Text(
                      localization.back_word,
                      style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.darkBlue),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Text(
                localization.enter_seed_phrase.overflow,
                style: themeStyle.styles.basicStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ColorsRes.text,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: isClearButtonState,
              builder: (_, isClear, __) {
                return TextPrimaryButton.appBar(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  text: isClear ? localization.clear : localization.paste,
                  style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.darkBlue),
                  onPressed: isClear ? _clearFields : _pastePhrase,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 30),
        Flexible(child: _buildPhrasesList(localization, themeStyle)),
        SizedBox(
          height: bottomPadding < kPrimaryButtonHeight ? 0 : bottomPadding - kPrimaryButtonHeight,
        ),
        PrimaryElevatedButton(
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
        suggestionBackground: ColorsRes.white,
        suggestionStyle: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
        textStyle: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
        requestNextField: () => focuses[index].requestFocus(),
        textInputAction: index == controllers.length ? TextInputAction.done : TextInputAction.next,
        confirmAction: _confirmAction,
      ),
    );
  }

  void _confirmAction() {
    if (formKey.currentState?.validate() ?? false) {
      FocusManager.instance.primaryFocus?.unfocus();
      final phrase = controllers.map((e) => e.text).toList();
      widget.onPhraseEntered(phrase);
    }
  }

  void _clearFields() {
    controllers.forEach((c) => c.clear());
    formKey.currentState?.reset();
  }

  Future<void> _pastePhrase() async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    final words = clipboard?.text?.split(kSeedSplitRegExp) ?? <String>[];

    if (words.isNotEmpty && words.length == wordsCount) {
      for (final word in words) {
        if (getHints(word).isEmpty) {
          words.clear();
          break;
        }
      }
    } else {
      words.clear();
    }

    if (words.isEmpty) {
      if (!mounted) return;

      formKey.currentState?.reset();

      showErrorFlushbar(
        context,
        message: context.localization.incorrect_words_format,
      );
      return;
    }

    words.asMap().forEach((index, word) {
      controllers[index].value = TextEditingValue(
        text: word,
        selection: TextSelection.fromPosition(TextPosition(offset: word.length)),
      );
    });
    focuses.forEach((f) => f.unfocus());
    formKey.currentState?.validate();
  }
}
