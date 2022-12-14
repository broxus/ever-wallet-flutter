import 'package:ever_wallet/application/common/general/field/suggestion_formatter.dart';
import 'package:ever_wallet/application/common/general/field/type_ahead_field.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/theme_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class SeedPhraseInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focus;
  final TextInputAction textInputAction;
  final String prefixText;

  /// Request focus of next field only when [textInputAction] next
  final VoidCallback requestNextField;

  /// Confirm entering all phrase only when [textInputAction] not next
  final VoidCallback confirmAction;

  final TextStyle? suggestionStyle;
  final Color? suggestionBackground;
  final TextStyle? textStyle;
  final Color? enabledBorderColor;

  const SeedPhraseInput({
    super.key,
    required this.controller,
    required this.focus,
    required this.requestNextField,
    required this.textInputAction,
    required this.prefixText,
    required this.confirmAction,
    this.suggestionStyle,
    this.suggestionBackground,
    this.textStyle,
    this.enabledBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.themeStyle;

    return EWTypeAheadField(
      itemBuilder: (_, suggestion) => itemBuilder(suggestion, themeStyle),
      onSuggestionSelected: onSuggestionSelected,
      suggestionsCallback: (_) => suggestionsCallback(),
      key: Key('SeedPhrase_$prefixText'),
      enabledBorderColor: enabledBorderColor,
      controller: controller,
      focusNode: focus,
      textInputAction: textInputAction,
      suggestionBackground: suggestionBackground,
      textStyle: textStyle,
      validator: (v) {
        final word = controller.text;
        if (word.isNotEmpty && getHints(word).contains(word)) {
          return null;
        }
        return '';
      },
      onSubmitted: (_) => _nextOrConfirm(),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 16, top: 11),
        child: Text(
          prefixText,
          style: themeStyle.styles.basicStyle.copyWith(
            color: themeStyle.colors.textSecondaryTextButtonColor,
          ),
        ),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')),
        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
        SuggestionFormatter(suggestions: getHints),
      ],
    );
  }

  List<String> suggestionsCallback() {
    final value = controller.value;
    if (value.text.isEmpty) return [];
    final text = value.text.substring(0, value.selection.start);
    final hints = getHints(text);
    if (hints.length == 1 && hints[0] == value.text) {
      return [];
    }
    return hints;
  }

  Widget itemBuilder(String suggestion, ThemeStyle themeStyle) {
    return ListTile(
      tileColor: Colors.transparent,
      title: Text(
        suggestion,
        style: suggestionStyle ??
            themeStyle.styles.basicStyle.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  void onSuggestionSelected(String suggestion) {
    controller.text = suggestion;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );

    _nextOrConfirm();
  }

  void _nextOrConfirm() {
    if (textInputAction != TextInputAction.next) {
      confirmAction();
    } else {
      requestNextField();
    }
  }
}
