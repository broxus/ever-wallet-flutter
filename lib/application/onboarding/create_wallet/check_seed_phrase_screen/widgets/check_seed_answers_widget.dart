import 'package:collection/collection.dart';
import 'package:ever_wallet/application/common/general/button/push_state_ink_widget.dart';
import 'package:ever_wallet/application/onboarding/create_wallet/check_seed_phrase_screen/check_seed_phrase_cubit.dart';
import 'package:ever_wallet/application/util/extensions/iterable_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:flutter/material.dart';

class CheckSeedAnswersWidget extends StatelessWidget {
  final List<CheckSeedCorrectAnswer> userAnswers;
  final int? currentIndex;

  final ValueChanged<String> clearAnswer;

  final Color pressColor;
  final Color borderColor;
  final Color currentBorderColor;
  final Color selectedTextColor;
  final Color notSelectedTextColor;

  const CheckSeedAnswersWidget({
    required this.userAnswers,
    required this.currentIndex,
    required this.clearAnswer,
    required this.pressColor,
    required this.borderColor,
    required this.currentBorderColor,
    required this.selectedTextColor,
    required this.notSelectedTextColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: userAnswers.mapIndexed(_answerBuilder).separated(const SizedBox(width: 16)),
    );
  }

  Widget _answerBuilder(int index, CheckSeedCorrectAnswer answer) {
    final isSelected = answer.word != '';
    final isCurrent = index == currentIndex;

    return Expanded(
      child: PushStateInkWidget(
        pressStateColor: pressColor,
        onPressed: isSelected ? () => clearAnswer(answer.word) : null,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isCurrent ? currentBorderColor : borderColor,
            ),
          ),
          child: Text(
            isSelected
                ? '${answer.wordIndex + 1}. ${answer.word}'
                : 'Word #${answer.wordIndex + 1}',
            style: StylesRes.captionText.copyWith(
              color: isSelected ? selectedTextColor : notSelectedTextColor,
            ),
          ),
        ),
      ),
    );
  }
}
