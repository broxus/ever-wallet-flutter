import 'dart:math' as math;

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../domain/constants/phrase_generation.dart';
import '../../domain/utils/phrase_check.dart';
import '../../logger.dart';
import '../design/design.dart';
import '../design/utils.dart';
import '../design/widget/crystal_scaffold.dart';
import '../router.gr.dart';

class SeedPhraseCheckPage extends StatefulWidget {
  final List<String> phrase;
  final String? seedName;

  const SeedPhraseCheckPage({
    Key? key,
    required this.phrase,
    this.seedName,
  }) : super(key: key);

  @override
  _SeedPhraseCheckPageState createState() => _SeedPhraseCheckPageState();
}

class _SeedPhraseCheckPageState extends State<SeedPhraseCheckPage> {
  late final Map<int, String> words;
  final formKey = GlobalKey<FormState>();
  final wordsFocuses = List.generate(kDefaultCheckingWordsAmount, (_) => FocusNode());
  final wordsControllers = List.generate(kDefaultCheckingWordsAmount, (_) => TextEditingController());
  final scrollController = ScrollController();
  final isFormValid = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    words = generateCheckingMap(widget.phrase);
    logger.d(words.toString());
  }

  @override
  void dispose() {
    for (var i = 0; i < kDefaultCheckingWordsAmount; i++) {
      wordsFocuses[i].dispose();
      wordsControllers[i].dispose();
    }
    isFormValid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CrystalScaffold(
        onScaffoldTap: FocusScope.of(context).unfocus,
        headline: LocaleKeys.seed_phrase_check_screen_title.tr(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
            physics: const ClampingScrollPhysics(),
            cacheExtent: context.screenSize.height,
            controller: scrollController,
            itemCount: words.length,
            itemBuilder: (context, index) => buildTextField(
              index: index,
              words: words,
            ),
            separatorBuilder: (_, __) => const CrystalDivider(height: 20),
            padding: EdgeInsets.only(
              top: 20,
              bottom: 32 + CrystalButton.kHeight + context.keyboardInsets.bottom,
            ),
          ),
        ),
      );

  Widget buildTextField({
    required int index,
    required Map<int, String> words,
  }) {
    final isLast = index == wordsControllers.length - 1;

    return CrystalTextFormField(
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
      onChanged: (_) {
        if (wordsControllers.every((e) => e.text.isNotEmpty)) {
          isFormValid.value = formKey.currentState?.validate() ?? false;
        }
      },
      onFieldSubmitted: (text) {
        if (!isLast) {
          wordsFocuses[index + 1].requestFocus();
        }
      },
      keyboardType: TextInputType.name,
      inputAction: isLast ? TextInputAction.done : TextInputAction.next,
      hintText: LocaleKeys.seed_phrase_check_screen_hint.tr(),
      style: CrystalTextFormField.kTextStyle.copyWith(fontSize: 14),
      hintStyle: CrystalTextFormField.kHintStyle.copyWith(fontSize: 14),
      enableInteractiveSelection: false,
      maxLength: 24,
      formatters: [
        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
        SuggestionFormatter(suggestions: getHints),
      ],
      scrollPadding: EdgeInsets.only(
        top: 56,
        bottom: context.keyboardInsets.bottom + CrystalButton.kHeight + 36,
      ),
      prefix: SizedBox(
        width: 28,
        child: Center(
          child: Text(
            '${words.entries.elementAt(index).key + 1}.',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: CrystalColor.fontDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildActions() => AnimatedPadding(
        curve: Curves.decelerate,
        duration: kThemeAnimationDuration,
        padding: EdgeInsets.only(
          bottom: math.max(getKeyboardInsetsBottom(context), 0) + 12,
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: isFormValid,
          builder: (context, value, child) => AnimatedAppearance(
            showing: value,
            child: CrystalButton(
              text: LocaleKeys.actions_confirm.tr(),
              onTap: onConfirm,
            ),
          ),
        ),
      );

  void onConfirm() {
    FocusScope.of(context).unfocus();
    context.router.push(PasswordCreationRoute(
      phrase: widget.phrase,
      seedName: widget.seedName,
    ));
  }
}
