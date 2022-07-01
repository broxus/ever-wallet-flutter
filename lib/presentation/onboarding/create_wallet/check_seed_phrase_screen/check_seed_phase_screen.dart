import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/general/button/primary_button.dart';
import '../../../common/general/default_appbar.dart';
import '../../../util/colors.dart';
import '../../../util/extensions/context_extensions.dart';
import '../../general_screens/create_password.dart';
import '../../widgets/onboarding_background.dart';
import 'check_seed_phrase_cubit.dart';

class CheckSeedPhraseRoute extends MaterialPageRoute<void> {
  CheckSeedPhraseRoute(List<String> phrase, String phraseName)
      : super(builder: (_) => CheckSeedPhraseScreen(phraseName: phraseName, phrase: phrase));
}

class CheckSeedPhraseScreen extends StatefulWidget {
  final List<String> phrase;
  final String phraseName;

  const CheckSeedPhraseScreen({
    Key? key,
    required this.phrase,
    required this.phraseName,
  }) : super(key: key);

  @override
  State<CheckSeedPhraseScreen> createState() => _CheckSeedPhraseScreenState();
}

class _CheckSeedPhraseScreenState extends State<CheckSeedPhraseScreen> {
  late CheckSeedPhraseCubit cubit;

  @override
  void initState() {
    cubit = CheckSeedPhraseCubit(
      widget.phrase,
      () => Navigator.of(context).push(CreatePasswordRoute(widget.phrase, widget.phraseName)),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localization;
    final themeStyle = context.themeStyle;

    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const DefaultAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(localization.check_seed_phrase, style: themeStyle.styles.appbarStyle),
              const SizedBox(height: 16),
              Text(
                // TODO: change text
                'Now let’s check that you wrote your seed phrase correctly. Please choose the correct words to continue.',
                style: themeStyle.styles.basicStyle,
              ),
              const Spacer(),
              BlocBuilder<CheckSeedPhraseCubit, CheckSeedPhraseCubitState>(
                bloc: cubit,
                builder: (context, state) => state.when(
                  answer: _buildCheckBody,
                  correct: (q, a) => _buildCheckBody(q, userAnswer: a, isError: false),
                  error: (q, a) => _buildCheckBody(q, userAnswer: a, isError: true),
                ),
              ),
            ],
          ),
        ),
      ),
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
          style: theme.styles.header2Style,
        ),
        const SizedBox(height: 32),
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
        isTransparent: true,
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
