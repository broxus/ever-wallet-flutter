import 'package:ever_wallet/application/common/general/button/primary_button.dart';
import 'package:ever_wallet/application/common/general/button/text_button.dart';
import 'package:ever_wallet/application/onboarding/create_wallet/check_seed_phrase_screen/check_seed_phrase_cubit.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddNewSeedValidateWidget extends StatefulWidget {
  const AddNewSeedValidateWidget({
    required this.backAction,
    required this.nextAction,
    required this.phrase,
    Key? key,
  }) : super(key: key);

  final List<String> phrase;
  final VoidCallback backAction;
  final VoidCallback nextAction;

  @override
  State<AddNewSeedValidateWidget> createState() => _AddNewSeedValidateWidgetState();
}

class _AddNewSeedValidateWidgetState extends State<AddNewSeedValidateWidget> {
  late CheckSeedPhraseCubit cubit;

  @override
  void initState() {
    cubit = CheckSeedPhraseCubit(widget.phrase, () => widget.nextAction());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localization;
    final themeStyle = context.themeStyle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Align(
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
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                localization.check_seed_phrase,
                textAlign: TextAlign.left,
                style: themeStyle.styles.basicStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ColorsRes.text,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          // TODO: change text
          'Now let’s check that you wrote your seed phrase correctly. Please choose the correct words to continue.',
          style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
        ),
        const SizedBox(height: 30),
        BlocBuilder<CheckSeedPhraseCubit, CheckSeedPhraseCubitState>(
          bloc: cubit,
          builder: (context, state) => state.when(
            answer: _buildCheckBody,
            correct: (q, a) => _buildCheckBody(q, userAnswer: a, isError: false),
            error: (q, a) => _buildCheckBody(q, userAnswer: a, isError: true),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckBody(CheckSeedPhraseQuestion question, {String? userAnswer, bool? isError}) {
    final theme = context.themeStyle;
    // final localization = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          /// TODO: replace text
          '${question.questionIndex + 1} of $kDefaultCheckPhraseAnswers',
          style: theme.styles.basicStyle.copyWith(color: theme.colors.textSecondaryTextButtonColor),
        ),
        const SizedBox(height: 8),
        Text(
          /// TODO: replace text
          'Select word #${question.wordOrderIndex + 1} from the seed',
          style: theme.styles.header2Style.copyWith(color: ColorsRes.text),
        ),
        const SizedBox(height: 16),
        ...question.answers
            .map(
              (a) => _answerButton(
                a,
                theme.colors,
                isError: userAnswer != null && a == userAnswer ? isError : null,
              ),
            )
            .toList(),
      ],
    );
  }

  /// [isError] = true - red button, false - green button, null - default
  Widget _answerButton(String answer, ColorsPalette colors, {bool? isError}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: PrimaryButton(
        text: answer,
        onPressed: () => cubit.answerQuestion(answer),
        backgroundColor: isError == null
            ? null
            : isError
                ? colors.errorInputColor.withAlpha(81)
                : colors.thirdButtonColor,
      ),
    );
  }
}
