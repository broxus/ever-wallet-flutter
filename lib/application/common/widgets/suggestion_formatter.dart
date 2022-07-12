import 'package:flutter/services.dart';

class SuggestionFormatter extends TextInputFormatter {
  final int minimalLength;
  final Iterable<String> Function(String) suggestions;
  final String Function(String)? afterClearSuggestionText;
  String? _oldText;
  bool _repeated = false;

  SuggestionFormatter({
    this.minimalLength = 1,
    required this.suggestions,
    this.afterClearSuggestionText,
  }) : assert(minimalLength > 0);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue _oldValue,
    TextEditingValue newValue,
  ) {
    TextEditingValue restrictedValue = newValue.copyWith(
      text: newValue.text.replaceAll('\u200B', '').trim(),
    );

    final oldValue = _oldValue.copyWith(
      text: _oldValue.text.replaceAll('\u200B', ''),
    );
    final newLength = restrictedValue.text.length;
    final isDeleting = oldValue.text.isNotEmpty &&
        oldValue.selection.baseOffset == restrictedValue.selection.baseOffset;

    final showingSuggestion = oldValue.selection.extentOffset - oldValue.selection.baseOffset > 1;

    if (newLength == minimalLength && isDeleting && showingSuggestion) {
      final length = newLength - 1;
      if (length > 0) {
        restrictedValue = restrictedValue.copyWith(
          text: newValue.text.substring(0, length),
          selection: TextSelection.collapsed(offset: length),
        );
      } else {
        restrictedValue = TextEditingValue.empty;
        if (afterClearSuggestionText != null) {
          final prevText = newValue.text.substring(0, minimalLength - 1);
          final text = afterClearSuggestionText!(prevText);
          restrictedValue = restrictedValue.copyWith(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );
        }
      }
    } else if (newLength >= minimalLength) {
      final suggestions = this.suggestions(newValue.text);

      if (suggestions.isNotEmpty) {
        final suggestion = suggestions.first;
        restrictedValue = restrictedValue.copyWith(
          text: suggestion,
          selection: TextSelection(
            baseOffset: newValue.text.length - (isDeleting && showingSuggestion ? 1 : 0),
            extentOffset: suggestions.first.length,
          ),
        );
      }
    }

    if (isDeleting && _repeated && _oldText == newValue.text) {
      restrictedValue = restrictedValue.copyWith(
        selection: restrictedValue.selection.copyWith(
          baseOffset: restrictedValue.selection.baseOffset - 1,
        ),
      );
      _repeated = false;
    }

    _repeated = isDeleting && _oldText == newValue.text;
    _oldText = newValue.text;

    return restrictedValue;
  }
}
