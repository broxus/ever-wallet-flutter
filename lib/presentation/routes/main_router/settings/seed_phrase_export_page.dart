import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../design/design.dart';
import '../../../design/widgets/crystal_title.dart';
import '../../../design/widgets/custom_back_button.dart';
import '../../../design/widgets/custom_outlined_button.dart';
import '../../../design/widgets/unfocusing_gesture_detector.dart';

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
        child: UnfocusingGestureDetector(
          child: Scaffold(
            appBar: AppBar(
              leading: const CustomBackButton(),
            ),
            body: body(),
          ),
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
                    const SizedBox(height: 8),
                    title(),
                    const SizedBox(height: 32),
                    words(),
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
        text: LocaleKeys.seed_phrase_save_screen_title.tr(),
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
        text: LocaleKeys.seed_phrase_save_screen_action_copy.tr(),
      );

  Future<void> onPressed() async {
    await Clipboard.setData(ClipboardData(text: widget.phrase.join(' ')));

    if (!mounted) return;

    showCrystalFlushbar(
      context,
      message: LocaleKeys.seed_phrase_save_screen_message_copied.tr(),
    );
  }
}
