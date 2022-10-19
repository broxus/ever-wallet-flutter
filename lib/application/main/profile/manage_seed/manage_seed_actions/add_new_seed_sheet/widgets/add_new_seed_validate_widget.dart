import 'package:ever_wallet/application/common/general/button/text_button.dart';
import 'package:ever_wallet/application/onboarding/create_wallet/check_seed_phrase_screen/check_seed_phrase_cubit.dart';
import 'package:ever_wallet/application/onboarding/create_wallet/check_seed_phrase_screen/widgets/check_seed_answers_widget.dart';
import 'package:ever_wallet/application/onboarding/create_wallet/check_seed_phrase_screen/widgets/check_seed_available_answers_widget.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddNewSeedValidateWidget extends StatefulWidget {
  const AddNewSeedValidateWidget({
    required this.backAction,
    required this.nextAction,
    required this.phrase,
    super.key,
  });

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
                        context.localization.back_word,
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
          localization.check_seed_phrase_correctly,
          style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
        ),
        const SizedBox(height: 30),
        BlocBuilder<CheckSeedPhraseCubit, CheckSeedPhraseCubitState>(
          bloc: cubit,
          builder: (context, state) => state.when(
            answer: (available, user, index) => _buildCheckBody(
              available,
              user,
              currentIndex: index,
              localization,
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
      ],
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
          borderColor: isError ? ColorsRes.redLight : ColorsRes.greyLight,
          currentBorderColor: ColorsRes.darkBlue.withOpacity(0.3),
          clearAnswer: cubit.clearAnswer,
          notSelectedTextColor: ColorsRes.grey,
          selectedTextColor: ColorsRes.black,
          pressColor: ColorsRes.greyOpacity,
        ),
        if (isError)
          Text(
            localization.seed_is_wrong,
            style: StylesRes.basicText.copyWith(color: ColorsRes.redLight),
          )
        else
          SizedBox(height: StylesRes.basicText.fontSize! * StylesRes.basicText.height!),
        const SizedBox(height: 70),
        CheckSeedAvailableAnswersWidget(
          availableAnswers: available,
          selectedAnswers: userAnswers.map((e) => e.word).toList(),
          selectAnswer: cubit.answerQuestion,
          borderColor: ColorsRes.greyLight,
          pressColor: ColorsRes.greyOpacity,
          textColor: ColorsRes.black,
        ),
      ],
    );
  }
}
