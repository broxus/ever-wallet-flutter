import 'package:ever_wallet/application/common/widgets/crystal_flushbar.dart';
import 'package:ever_wallet/application/common/widgets/crystal_title.dart';
import 'package:ever_wallet/application/common/widgets/custom_back_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';

class SeedPhraseExportPage extends StatefulWidget {
  final List<String> phrase;

  const SeedPhraseExportPage({
    Key? key,
    required this.phrase,
  }) : super(key: key);

  @override
  State<SeedPhraseExportPage> createState() => _SeedPhraseExportPageState();
}

class _SeedPhraseExportPageState extends State<SeedPhraseExportPage> {
  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          appBar: AppBar(
            leading: const CustomBackButton(),
          ),
          body: body(),
        ),
      );

  Widget body() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16) - const EdgeInsets.only(top: 16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Gap(8),
                    title(),
                    const Gap(32),
                    words(),
                    const Gap(64),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    copyButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget title() => CrystalTitle(
        text: AppLocalizations.of(context)!.save_seed_phrase,
      );

  Widget words() => Row(
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
      );

  Widget column({
    required int initial,
    required int end,
  }) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = initial; i < end; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  index(i),
                  Expanded(
                    child: word(i),
                  ),
                ],
              ),
            ),
        ],
      );

  Widget index(int i) => Text(
        '${i + 1}. ',
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black26,
        ),
      );

  Widget word(int i) => Text(
        widget.phrase[i],
        style: const TextStyle(
          fontSize: 16,
        ),
      );

  Widget copyButton() => CustomOutlinedButton(
        onPressed: onPressed,
        text: AppLocalizations.of(context)!.copy_words,
      );

  Future<void> onPressed() async {
    await Clipboard.setData(ClipboardData(text: widget.phrase.join(' ')));

    if (!mounted) return;

    showFlushbar(
      context,
      message: AppLocalizations.of(context)!.copied,
    );
  }
}
