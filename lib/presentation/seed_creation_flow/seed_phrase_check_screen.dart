import 'dart:math' as math;

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../domain/constants/phrase_generation.dart';
import '../../domain/utils/phrase_check.dart';
import '../design/design.dart';
import '../design/utils.dart';
import '../welcome/widget/welcome_scaffold.dart';

class SeedPhraseCheckScreen extends StatefulWidget {
  final List<String> phrase;
  final String seedName;

  const SeedPhraseCheckScreen({
    Key? key,
    required this.phrase,
    required this.seedName,
  }) : super(key: key);

  @override
  _SeedPhraseCheckScreenState createState() => _SeedPhraseCheckScreenState();
}

class _SeedPhraseCheckScreenState extends State<SeedPhraseCheckScreen> {
  late final Map<int, String> words;
  final formKey = GlobalKey<FormState>();
  final wordsFocuses = List.generate(defaultCheckingWordsAmount, (_) => FocusNode());
  final wordsControllers = List.generate(defaultCheckingWordsAmount, (_) => TextEditingController());
  final textListScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    words = generateCheckingMap(widget.phrase);
    debugPrint(words.toString());

    WidgetsBinding.instance?.addPostFrameCallback(
      (timeStamp) {
        Future.delayed(
          const Duration(seconds: 1),
          () {
            if (mounted && wordsFocuses.where((e) => e.hasFocus).isEmpty) {
              wordsFocuses.first.requestFocus();
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    for (var i = 0; i < defaultCheckingWordsAmount; i++) {
      wordsFocuses[i].dispose();
      wordsControllers[i].dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WelcomeScaffold(
        allowIosBackSwipe: false,
        onScaffoldTap: FocusScope.of(context).unfocus,
        headline: LocaleKeys.seed_phrase_check_screen_title.tr(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Stack(
            children: [
              SizedBox.expand(child: buildTextFieldList(words)),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: buildActions(),
              ),
            ],
          ),
        ),
      );

  Widget buildTextFieldList(Map<int, String> words) => Form(
        key: formKey,
        child: FadingEdgeScrollView.fromScrollView(
          shouldDisposeScrollController: true,
          child: ListView.separated(
            cacheExtent: context.screenSize.height,
            controller: textListScrollController,
            itemCount: words.length,
            itemBuilder: (context, index) => buildTextField(
              index: index,
              words: words,
            ),
            separatorBuilder: (_, __) => const CrystalDivider(height: 20.0),
            padding: EdgeInsets.only(
              top: 20.0,
              bottom: (context.keyboardInsets.bottom > 0
                      ? context.keyboardInsets.bottom + 144
                      : CrystalButton.kHeight + 12.0) +
                  (CrystalButton.kHeight + 12.0),
            ),
          ),
        ),
      );

  Widget buildTextField({
    required int index,
    required Map<int, String> words,
  }) {
    final isLast = index == defaultCheckingWordsAmount - 1;
    return CrystalTextField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == widget.phrase[words.entries.elementAt(index).key]) {
          return null;
        } else {
          return LocaleKeys.seed_phrase_check_screen_validation_errors_incorrect_word.tr();
        }
      },
      controller: wordsControllers[index],
      focusNode: wordsFocuses[index],
      autocorrect: false,
      onFieldSubmitted: (text) {
        if (!isLast) {
          wordsFocuses[index + 1].requestFocus();
        }
      },
      keyboardType: TextInputType.name,
      inputAction: isLast ? TextInputAction.done : TextInputAction.next,
      hintText: LocaleKeys.seed_phrase_check_screen_hint.tr(),
      style: CrystalTextField.kTextStyle.copyWith(fontSize: 14),
      hintStyle: CrystalTextField.kHintStyle.copyWith(fontSize: 14),
      enableInteractiveSelection: false,
      maxLength: 24,
      formatters: [
        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
        SuggestionFormatter(suggestions: getHints),
      ],
      scrollPadding: EdgeInsets.only(
        top: 56.0,
        bottom: context.keyboardInsets.bottom + CrystalButton.kHeight + 36,
      ),
      prefix: SizedBox(
        width: 28,
        child: Center(
          child: AnimatedAppearance(
            delay: Duration(milliseconds: 200 * (index + 1)),
            duration: const Duration(milliseconds: 400),
            offset: const Offset(-0.5, -0.5),
            child: Text(
              '${words.entries.elementAt(index).key + 1}.',
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                color: CrystalColor.fontDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildActions() {
    final showing = wordsControllers.map((e) => e.text.isNotEmpty).reduce((value, element) => value && element) &&
        (formKey.currentState?.validate() ?? false);
    return AnimatedPadding(
      curve: Curves.decelerate,
      duration: kThemeAnimationDuration,
      padding: EdgeInsets.only(
        bottom: math.max(
              getKeyboardInsetsBottom(context),
              0,
            ) +
            12,
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge(wordsControllers),
        builder: (context, child) => AnimatedAppearance(
          showing: showing,
          child: CrystalButton(
            text: LocaleKeys.actions_confirm.tr(),
            onTap: onConfirm,
          ),
        ),
      ),
    );
  }

  void onConfirm() {
    FocusScope.of(context).unfocus();
    context.router.push(PasswordCreationScreenRoute(
      phrase: widget.phrase,
      seedName: widget.seedName,
    ));
  }
}
