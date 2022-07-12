import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/widgets/crystal_flushbar.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SeedPhraseExportSheet extends StatefulWidget {
  final List<String> phrase;

  const SeedPhraseExportSheet({
    Key? key,
    required this.phrase,
  }) : super(key: key);

  @override
  State<SeedPhraseExportSheet> createState() => _SeedPhraseExportSheetState();
}

class _SeedPhraseExportSheetState extends State<SeedPhraseExportSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: column(
                initial: 0,
                end: widget.phrase.length ~/ 2,
              ),
            ),
            Expanded(
              child: column(
                initial: widget.phrase.length ~/ 2,
                end: widget.phrase.length,
              ),
            ),
          ],
        ),
        const SizedBox(height: 60),
        PrimaryElevatedButton(
          onPressed: onPressed,
          text: context.localization.copy_words,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget column({
    required int initial,
    required int end,
  }) {
    final style = context.themeStyle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = initial; i < end; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text(
                  '${i + 1}. ',
                  style: style.styles.basicStyle.copyWith(color: ColorsRes.grey),
                ),
                Expanded(
                  child: Text(
                    widget.phrase[i],
                    style: style.styles.basicStyle.copyWith(color: ColorsRes.text),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> onPressed() async {
    await Clipboard.setData(ClipboardData(text: widget.phrase.join(' ')));

    if (!mounted) return;

    showFlushbar(
      context,
      message: AppLocalizations.of(context)!.copied,
    );
  }
}
