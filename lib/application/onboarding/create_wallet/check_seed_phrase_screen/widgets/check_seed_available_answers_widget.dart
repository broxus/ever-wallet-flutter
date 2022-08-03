import 'package:dotted_border/dotted_border.dart';
import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/general/button/push_state_ink_widget.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/iterable_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:flutter/material.dart';

class CheckSeedAvailableAnswersWidget extends StatelessWidget {
  final List<String> availableAnswers;
  final List<String> selectedAnswers;
  final ValueChanged<String> selectAnswer;

  final Color pressColor;
  final Color borderColor;
  final Color textColor;

  const CheckSeedAvailableAnswersWidget({
    required this.availableAnswers,
    required this.selectedAnswers,
    required this.selectAnswer,
    required this.pressColor,
    this.borderColor = ColorsRes.grey,
    this.textColor = ColorsRes.white,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < kDefaultWordsToCheckAmount; index++) ...[
          _answersRow(
            availableAnswers.sublist(
              index * kDefaultWordsToCheckAmount,
              index * kDefaultWordsToCheckAmount + kDefaultWordsToCheckAmount,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _answersRow(List<String> answers) {
    return Row(
      children: answers.map(_answerBuilder).separated(const SizedBox(width: 8)),
    );
  }

  Widget _answerBuilder(String answer) {
    final isSelected = selectedAnswers.contains(answer);

    return Expanded(
      child: PushStateInkWidget(
        pressStateColor: pressColor,
        onPressed: isSelected ? null : () => selectAnswer(answer),
        child: DottedBorder(
          dashPattern: isSelected ? const [4, 4] : const [1, 0],
          color: borderColor,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Text(
                isSelected ? '' : answer,
                style: StylesRes.captionText.copyWith(color: textColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
