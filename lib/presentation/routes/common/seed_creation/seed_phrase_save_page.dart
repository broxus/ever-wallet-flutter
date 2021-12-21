import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../design/design.dart';
import '../../../design/phrase_generation.dart';
import '../../../design/widgets/animated_fade_slide_in.dart';
import '../../../design/widgets/crystal_flushbar.dart';
import '../../../design/widgets/crystal_title.dart';
import '../../../design/widgets/custom_back_button.dart';
import '../../../design/widgets/custom_elevated_button.dart';
import '../../../design/widgets/custom_outlined_button.dart';
import '../../router.gr.dart';

class SeedPhraseSavePage extends StatefulWidget {
  final String? seedName;

  const SeedPhraseSavePage({
    Key? key,
    required this.seedName,
  }) : super(key: key);

  @override
  State<SeedPhraseSavePage> createState() => _SeedPhraseSavePageState();
}

class _SeedPhraseSavePageState extends State<SeedPhraseSavePage> {
  final key = generateKey(kDefaultMnemonicType);

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
                    const SizedBox(height: 8),
                    title(),
                    const SizedBox(height: 32),
                    words(),
                    const SizedBox(height: 128),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    submitButton(),
                    const SizedBox(height: 16),
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
              end: key.words.length ~/ 2,
            ),
          ),
          Expanded(
            child: column(
              initial: key.words.length ~/ 2,
              end: key.words.length,
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
        key.words[i],
        style: const TextStyle(
          fontSize: 16,
        ),
      );

  Widget submitButton() => AnimatedFadeSlideIn(
        duration: const Duration(milliseconds: 300),
        delay: const Duration(seconds: 1),
        offset: const Offset(0, 1),
        child: CustomElevatedButton(
          onPressed: onSubmitButtonPressed,
          text: LocaleKeys.seed_phrase_save_screen_action_confirm.tr(),
        ),
      );

  Future<void> onSubmitButtonPressed() => context.router.push(
        SeedPhraseCheckRoute(
          phrase: key.words,
          seedName: widget.seedName,
        ),
      );

  Widget copyButton() => CustomOutlinedButton(
        onPressed: onCopyButtonPressed,
        text: LocaleKeys.seed_phrase_save_screen_action_copy.tr(),
      );

  Future<void> onCopyButtonPressed() async {
    await Clipboard.setData(ClipboardData(text: key.words.join(' ')));

    if (!mounted) return;

    showCrystalFlushbar(
      context,
      message: LocaleKeys.seed_phrase_save_screen_message_copied.tr(),
    );
  }
}
