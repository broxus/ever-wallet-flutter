import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../common/utils.dart';

part 'check_seed_phrase_cubit.freezed.dart';

const kDefaultCheckPhraseAnswers = 3;
const delayBeforeChangeQuestion = Duration(seconds: 1);

class CheckSeedPhraseCubit extends Cubit<CheckSeedPhraseCubitState> {
  final List<String> originalPhrase;
  final List<CheckSeedPhraseQuestion> questionsForCheck;

  /// Navigate to other screen
  final VoidCallback completeChecking;

  factory CheckSeedPhraseCubit(List<String> originalPhrase, VoidCallback completeChecking) {
    return CheckSeedPhraseCubit._(
      originalPhrase,
      completeChecking,
      _generateCheckList(originalPhrase),
    );
  }

  CheckSeedPhraseCubit._(this.originalPhrase, this.completeChecking, this.questionsForCheck)
      : super(CheckSeedPhraseCubitState.answer(questionsForCheck.first));

  void answerQuestion(String answer) {
    if (state is _Correct) return;
    final question = state.question;

    if (question.correctPhrase == answer) {
      emit(CheckSeedPhraseCubitState.correct(question, answer));

      Future.delayed(delayBeforeChangeQuestion, () {
        if (question.questionIndex == kDefaultCheckPhraseAnswers - 1) {
          completeChecking();
        } else {
          emit(CheckSeedPhraseCubitState.answer(questionsForCheck[question.questionIndex + 1]));
        }
      });
    } else {
      emit(CheckSeedPhraseCubitState.error(question, answer));
    }
  }

  static List<CheckSeedPhraseQuestion> _generateCheckList(List<String> phrase) {
    /// TODO: move generateCheckingMap inside this class after removing old pages
    final wordsToCheck = generateCheckingMap(phrase);
    final dictionary = getHints('');
    final questionsList = <CheckSeedPhraseQuestion>[];
    final random = Random();

    for (final checked in wordsToCheck.entries) {
      final availableAnswers = [checked.value];

      while (availableAnswers.length != kDefaultCheckPhraseAnswers) {
        final number = random.nextInt(dictionary.length);
        if (availableAnswers.contains(dictionary[number])) {
          continue;
        }
        availableAnswers.add(dictionary[number]);
      }
      // to be sure it is shuffled
      availableAnswers
        ..shuffle()
        ..shuffle()
        ..shuffle();

      questionsList.add(
        CheckSeedPhraseQuestion(
          wordOrderIndex: checked.key,
          correctPhrase: checked.value,
          answers: availableAnswers,
          questionIndex: questionsList.length,
        ),
      );
    }
    return questionsList;
  }
}

@freezed
class CheckSeedPhraseCubitState with _$CheckSeedPhraseCubitState {
  /// Display answer without any selections
  const factory CheckSeedPhraseCubitState.answer(CheckSeedPhraseQuestion question) = _Answer;

  /// Correct selection. Other selections must be blocked.
  /// Question will change automatically
  const factory CheckSeedPhraseCubitState.correct(
    CheckSeedPhraseQuestion question,
    String userAnswer,
  ) = _Correct;

  /// Error selection
  const factory CheckSeedPhraseCubitState.error(
    CheckSeedPhraseQuestion question,
    String userAnswer,
  ) = _Error;
}

class CheckSeedPhraseQuestion {
  /// Index of word in original phrase. Start with 0
  final int wordOrderIndex;

  /// Index of question in answers list. Starts with 0
  final int questionIndex;

  final String correctPhrase;
  final List<String> answers;

  CheckSeedPhraseQuestion({
    required this.wordOrderIndex,
    required this.correctPhrase,
    required this.answers,
    required this.questionIndex,
  });
}
