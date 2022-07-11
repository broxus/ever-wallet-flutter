import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../util/extensions/context_extensions.dart';
import '../../../util/theme_styles.dart';
import '../../widgets/custom_type_ahead_field.dart';
import '../../widgets/suggestion_formatter.dart';

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

  const SeedPhraseInput({
    Key? key,
    required this.controller,
    required this.focus,
    required this.requestNextField,
    required this.textInputAction,
    required this.prefixText,
    required this.confirmAction,
    this.suggestionStyle,
    this.suggestionBackground,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.themeStyle;

    return CustomTypeAheadField(
      itemBuilder: (_, suggestion) => itemBuilder(suggestion, themeStyle),
      onSuggestionSelected: onSuggestionSelected,
      suggestionsCallback: (_) => suggestionsCallback(),
      key: Key('SeedPhrase_$prefixText'),
      controller: controller,
      focusNode: focus,
      textInputAction: textInputAction,
      suggestionBackground: suggestionBackground,
      textStyle: textStyle,
      validator: (v) {
        if (controller.text.isNotEmpty) {
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
    final text = value.text.substring(0, value.selection.start);
    return getHints(text);
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
