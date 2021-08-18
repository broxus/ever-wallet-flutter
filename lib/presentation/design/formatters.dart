import 'package:flutter/services.dart';

class AmountInputFormatter extends TextInputFormatter {
  final int integerDigits;
  final int fractionDigits;

  AmountInputFormatter({
    this.integerDigits = 7,
    this.fractionDigits = 9,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldText = oldValue.text;
    final newText = newValue.text;
    final oldSelection = oldValue.selection;
    final newSelection = newValue.selection;

    if (newSelection.baseOffset == 0) {
      return newValue;
    }

    String? formattedText = newText.replaceAll(',', '.');

    final regExp = RegExp('\\d{0,$integerDigits}(\\.\\d{0,$fractionDigits})?');
    formattedText = regExp.stringMatch(formattedText);

    TextSelection formattedSelection = newSelection;
    if (formattedText != null && formattedText.length == oldText.length) {
      formattedText = oldText;
      formattedSelection = oldSelection;
    }

    return newValue.copyWith(
      text: formattedText,
      selection: formattedSelection,
    );
  }
}
