import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/seed_creation/seed_phrase_check_screen.dart';
import 'package:ever_wallet/application/common/widgets/animated_fade_slide_in.dart';
import 'package:ever_wallet/application/common/widgets/crystal_flushbar.dart';
import 'package:ever_wallet/application/common/widgets/crystal_title.dart';
import 'package:ever_wallet/application/common/widgets/custom_back_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_elevated_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class SeedPhraseSaveScreen extends StatefulWidget {
  final String? seedName;

  const SeedPhraseSaveScreen({
    Key? key,
    required this.seedName,
  }) : super(key: key);

  @override
  State<SeedPhraseSaveScreen> createState() => _SeedPhraseSaveScreenState();
}

class _SeedPhraseSaveScreenState extends State<SeedPhraseSaveScreen> {
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
        text: AppLocalizations.of(context)!.save_seed_phrase,
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
          text: AppLocalizations.of(context)!.confirm_seed_saved,
        ),
      );

  Future<void> onSubmitButtonPressed() => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SeedPhraseCheckScreen(
            phrase: key.words,
            seedName: widget.seedName,
          ),
        ),
      );

  Widget copyButton() => CustomOutlinedButton(
        onPressed: onCopyButtonPressed,
        text: AppLocalizations.of(context)!.copy_words,
      );

  Future<void> onCopyButtonPressed() async {
    await Clipboard.setData(ClipboardData(text: key.words.join(' ')));

    if (!mounted) return;

    showCrystalFlushbar(
      context,
      message: AppLocalizations.of(context)!.copied,
    );
  }
}
