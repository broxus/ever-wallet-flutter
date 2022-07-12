import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/general/button/text_button.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/extensions/iterable_extensions.dart';
import 'package:ever_wallet/application/util/theme_styles.dart';
import 'package:flutter/material.dart';

class AddNewSeedSaveWidget extends StatefulWidget {
  const AddNewSeedSaveWidget({
    required this.backAction,
    required this.nextAction,
    required this.phrase,
    Key? key,
  }) : super(key: key);

  final VoidCallback backAction;
  final VoidCallback nextAction;

  final List<String> phrase;

  @override
  State<AddNewSeedSaveWidget> createState() => _AddNewSeedSaveWidgetState();
}

class _AddNewSeedSaveWidgetState extends State<AddNewSeedSaveWidget> {
  @override
  Widget build(BuildContext context) {
    final localization = context.localization;
    final themeStyle = context.themeStyle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
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
            ),
            Text(
              localization.save_seed_phrase,
              style: themeStyle.styles.basicStyle.copyWith(
                fontWeight: FontWeight.w700,
                color: ColorsRes.text,
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.phrase
                    .getRange(0, 6)
                    .mapIndex((word, i) => _textPair(word, i + 1, themeStyle))
                    .toList(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.phrase
                    .getRange(6, 12)
                    .mapIndex((word, i) => _textPair(word, i + 7, themeStyle))
                    .toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        PrimaryElevatedButton(
          onPressed: widget.nextAction,
          text: localization.confirm_seed_saved,
        ),
      ],
    );
  }

  Widget _textPair(String word, int index, ThemeStyle themeStyle) {
    final style = themeStyle.styles.basicStyle;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$index.',
              style: style.copyWith(color: ColorsRes.grey),
            ),
          ),
          Expanded(
            child: Text(
              word,
              style: style.copyWith(color: ColorsRes.text),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
