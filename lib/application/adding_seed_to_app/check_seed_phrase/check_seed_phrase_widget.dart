import 'package:ever_wallet/application/adding_seed_to_app/check_seed_phrase/check_seed_phrase_cubit.dart';
import 'package:ever_wallet/application/adding_seed_to_app/check_seed_phrase/widgets/check_seed_answers_widget.dart';
import 'package:ever_wallet/application/adding_seed_to_app/check_seed_phrase/widgets/check_seed_available_answers_widget.dart';
import 'package:ever_wallet/application/common/general/button/text_button.dart';
import 'package:ever_wallet/application/common/general/onboarding_appbar.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef CheckSeedPhraseNavigationCallback = void Function(BuildContext context);

class CheckSeedPhraseWidget extends StatefulWidget {
  const CheckSeedPhraseWidget({
    required this.phrase,
    required this.navigateToPassword,
    required this.primaryColor,
    required this.defaultTextColor,
    required this.secondaryTextColor,
    required this.errorColor,
    required this.defaultBorderColor,
    required this.availableAnswersTextColor,
    required this.notSelectedTextColor,
    super.key,
  });

  final List<String> phrase;
  final CheckSeedPhraseNavigationCallback navigateToPassword;

  final Color primaryColor;
  final Color defaultTextColor;
  final Color secondaryTextColor;
  final Color errorColor;
  final Color defaultBorderColor;
  final Color availableAnswersTextColor;
  final Color notSelectedTextColor;

  @override
  State<CheckSeedPhraseWidget> createState() => _CheckSeedPhraseWidgetState();
}

class _CheckSeedPhraseWidgetState extends State<CheckSeedPhraseWidget> {
  late CheckSeedPhraseCubit cubit;

  @override
  void initState() {
    cubit = CheckSeedPhraseCubit(widget.phrase, _navigateToPassword);
    super.initState();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  void _navigateToPassword() => widget.navigateToPassword(context);

  @override
  Widget build(BuildContext context) {
    final localization = context.localization;
    final themeStyle = context.themeStyle;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: OnboardingAppBar(
        backColor: widget.primaryColor,
        actions: [
          TextPrimaryButton.appBar(
            text: localization.skip_word,
            style: themeStyle.styles.basicStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: widget.primaryColor,
            ),
            onPressed: _navigateToPassword,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization.check_seed_phrase,
              style: themeStyle.styles.appbarStyle.copyWith(color: widget.defaultTextColor),
            ),
            const SizedBox(height: 16),
            Text(
              localization.check_seed_phrase_correctly,
              style: themeStyle.styles.basicStyle.copyWith(color: widget.secondaryTextColor),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: BlocBuilder<CheckSeedPhraseCubit, CheckSeedPhraseCubitState>(
                bloc: cubit,
                builder: (context, state) => state.when(
                  answer: (available, user, index) => _buildCheckBody(
                    available,
                    user,
                    localization,
                    currentIndex: index,
                  ),
                  correct: (available, user) => _buildCheckBody(
                    available,
                    user,
                    localization,
                  ),
                  error: (available, user) => _buildCheckBody(
                    available,
                    user,
                    localization,
                    isError: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckBody(
    List<String> available,
    List<CheckSeedCorrectAnswer> userAnswers,
    AppLocalizations localization, {
    int? currentIndex,
    bool isError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckSeedAnswersWidget(
          userAnswers: userAnswers,
          currentIndex: currentIndex,
          borderColor: isError ? widget.errorColor : widget.defaultBorderColor,
          currentBorderColor: widget.primaryColor,
          clearAnswer: cubit.clearAnswer,
          notSelectedTextColor: widget.notSelectedTextColor,
          selectedTextColor: widget.defaultTextColor,
          pressColor: widget.primaryColor.withOpacity(0.2),
        ),
        if (isError)
          Text(
            localization.seed_is_wrong,
            style: StylesRes.basicText.copyWith(color: widget.errorColor),
          ),
        const Spacer(),
        CheckSeedAvailableAnswersWidget(
          availableAnswers: available,
          selectedAnswers: userAnswers.map((e) => e.word).toList(),
          selectAnswer: cubit.answerQuestion,
          pressColor: widget.primaryColor.withOpacity(0.2),
          borderColor: widget.primaryColor.withOpacity(0.5),
          textColor: widget.availableAnswersTextColor,
        ),
      ],
    );
  }
}
