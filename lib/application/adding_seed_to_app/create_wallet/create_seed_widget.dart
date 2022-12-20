import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/general/button/primary_button.dart';
import 'package:ever_wallet/application/common/general/button/text_button.dart';
import 'package:ever_wallet/application/common/general/onboarding_appbar.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/extensions/iterable_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:ever_wallet/application/util/theme_styles.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

typedef CreateSeedNavigationCallback = void Function(BuildContext context, List<String> phrase);

class CreateSeedWidget extends StatefulWidget {
  const CreateSeedWidget({
    required this.skipCallback,
    required this.checkCallback,
    required this.primaryColor,
    required this.defaultTextColor,
    required this.secondaryTextColor,
    required this.phraseBackgroundColor,
    required this.checkButtonTextColor,
    required this.skipButtonColor,
    required this.needSkipButtonBorder,
    super.key,
  });

  final CreateSeedNavigationCallback skipCallback;
  final CreateSeedNavigationCallback checkCallback;

  final Color primaryColor;
  final Color defaultTextColor;
  final Color secondaryTextColor;
  final Color phraseBackgroundColor;
  final Color checkButtonTextColor;
  final Color skipButtonColor;
  final bool needSkipButtonBorder;

  @override
  State<CreateSeedWidget> createState() => _CreateSeedWidgetState();
}

class _CreateSeedWidgetState extends State<CreateSeedWidget> {
  final key = generateKey(kDefaultMnemonicType);
  final isCopied = ValueNotifier<bool>(false);

  List<String> get words => key.words;

  @override
  Widget build(BuildContext context) {
    final localization = context.localization;
    final themeStyle = context.themeStyle;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      appBar: OnboardingAppBar(backColor: widget.primaryColor),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization.save_seed_phrase,
              style: StylesRes.sheetHeaderTextFaktum.copyWith(color: widget.defaultTextColor),
            ),
            const SizedBox(height: 12),
            Text(
              localization.save_seed_warning,
              style: themeStyle.styles.basicStyle.copyWith(color: widget.secondaryTextColor),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          color: widget.phraseBackgroundColor,
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: words
                                      .getRange(0, 6)
                                      .mapIndex((word, i) => _textPair(word, i + 1, themeStyle))
                                      .toList(),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: words
                                      .getRange(6, 12)
                                      .mapIndex((word, i) => _textPair(word, i + 7, themeStyle))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable: isCopied,
                          builder: (_, copied, __) {
                            if (copied) {
                              return SizedBox(
                                height: kPrimaryButtonHeight,
                                child: Align(
                                  child: Text(
                                    localization.copied_no_exclamation,
                                    style: themeStyle.styles.basicStyle
                                        .copyWith(color: ColorsRes.green400),
                                  ),
                                ),
                              );
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextPrimaryButton(
                                  icon: Assets.images.copy.svg(color: widget.primaryColor),
                                  fillWidth: false,
                                  text: localization.copy_words,
                                  style: themeStyle.styles.basicStyle
                                      .copyWith(color: widget.primaryColor),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: words.join(' ')));
                                    isCopied.value = true;
                                    Future.delayed(const Duration(seconds: 2), () {
                                      isCopied.value = false;
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        // To allow scroll above buttons
                        const SizedBox(height: kPrimaryButtonHeight * 2 + 12),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Column(
                      children: [
                        PrimaryButton(
                          text: localization.check_seed_phrase,
                          style: StylesRes.buttonText.copyWith(color: widget.checkButtonTextColor),
                          backgroundColor: widget.primaryColor,
                          onPressed: () => widget.checkCallback(context, words),
                        ),
                        const SizedBox(height: 12),
                        PrimaryButton(
                          backgroundColor: widget.skipButtonColor,
                          style: StylesRes.buttonText.copyWith(color: widget.primaryColor),
                          text: localization.skip_take_risk,
                          onPressed: () => widget.skipCallback(context, words),
                          border: !widget.needSkipButtonBorder
                              ? null
                              : Border.all(color: widget.primaryColor),
                          isTransparent: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textPair(String word, int index, ThemeStyle themeStyle) {
    final style = themeStyle.styles.basicStyle.copyWith(color: widget.defaultTextColor);
    final colors = themeStyle.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$index.',
              style: style.copyWith(color: colors.textSecondaryTextButtonColor),
            ),
          ),
          Expanded(
            child: Text(word, style: style, textAlign: TextAlign.left),
          ),
        ],
      ),
    );
  }
}
