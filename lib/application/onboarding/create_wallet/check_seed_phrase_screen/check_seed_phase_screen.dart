import 'package:ever_wallet/application/common/general/button/text_button.dart';
import 'package:ever_wallet/application/common/general/onboarding_appbar.dart';
import 'package:ever_wallet/application/onboarding/create_wallet/check_seed_phrase_screen/check_seed_phrase_cubit.dart';
import 'package:ever_wallet/application/onboarding/create_wallet/check_seed_phrase_screen/widgets/check_seed_answers_widget.dart';
import 'package:ever_wallet/application/onboarding/create_wallet/check_seed_phrase_screen/widgets/check_seed_available_answers_widget.dart';
import 'package:ever_wallet/application/onboarding/general_screens/create_password.dart';
import 'package:ever_wallet/application/onboarding/widgets/onboarding_background.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckSeedPhraseRoute extends MaterialPageRoute<void> {
  CheckSeedPhraseRoute(List<String> phrase)
      : super(builder: (_) => CheckSeedPhraseScreen(phrase: phrase));
}

class CheckSeedPhraseScreen extends StatefulWidget {
  final List<String> phrase;

  const CheckSeedPhraseScreen({
    Key? key,
    required this.phrase,
  }) : super(key: key);

  @override
  State<CheckSeedPhraseScreen> createState() => _CheckSeedPhraseScreenState();
}

class _CheckSeedPhraseScreenState extends State<CheckSeedPhraseScreen> {
  late CheckSeedPhraseCubit cubit;

  @override
  void initState() {
    cubit = CheckSeedPhraseCubit(widget.phrase, _navigateToPassword);
    super.initState();
  }

  void _navigateToPassword() {
    Navigator.of(context).push(CreatePasswordRoute(widget.phrase));
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localization;
    final themeStyle = context.themeStyle;

    return OnboardingBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: OnboardingAppBar(
          actions: [
            TextPrimaryButton.appBar(
              // TODO: replace text
              text: 'Skip',
              style: themeStyle.styles.basicStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: themeStyle.colors.primaryButtonColor,
              ),
              onPressed: _navigateToPassword,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(localization.check_seed_phrase, style: themeStyle.styles.appbarStyle),
              const SizedBox(height: 16),
              Text(
                // TODO: change text
                'Now let???s check that you wrote your seed phrase correctly. Please choose the correct words to continue.',
                style: themeStyle.styles.basicStyle,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: BlocBuilder<CheckSeedPhraseCubit, CheckSeedPhraseCubitState>(
                  bloc: cubit,
                  builder: (context, state) => state.when(
                    answer: (available, user, index) => _buildCheckBody(
                      available,
                      user,
                      currentIndex: index,
                    ),
                    correct: (available, user) => _buildCheckBody(available, user),
                    error: (available, user) => _buildCheckBody(available, user, isError: true),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckBody(
    List<String> available,
    List<CheckSeedCorrectAnswer> userAnswers, {
    int? currentIndex,
    bool isError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckSeedAnswersWidget(
          userAnswers: userAnswers,
          currentIndex: currentIndex,
          borderColor: isError ? ColorsRes.redDark : ColorsRes.whiteOpacity,
          currentBorderColor: ColorsRes.lightBlue.withOpacity(0.5),
          clearAnswer: cubit.clearAnswer,
          notSelectedTextColor: ColorsRes.grey,
          selectedTextColor: ColorsRes.white,
          pressColor: ColorsRes.lightBlue.withOpacity(0.2),
        ),
        if (isError)
          Text(
            // TODO: replace text
            'The seed phrase is wrong',
            style: StylesRes.basicText.copyWith(color: ColorsRes.redDark),
          ),
        const Spacer(),
        CheckSeedAvailableAnswersWidget(
          availableAnswers: available,
          selectedAnswers: userAnswers.map((e) => e.word).toList(),
          selectAnswer: cubit.answerQuestion,
          pressColor: ColorsRes.lightBlue.withOpacity(0.2),
        ),
      ],
    );
  }
}
