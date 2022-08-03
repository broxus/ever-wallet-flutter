import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:ever_wallet/application/common/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'check_seed_phrase_cubit.freezed.dart';

const delayBeforeCompleteChecking = Duration(seconds: 1);

class CheckSeedPhraseCubit extends Cubit<CheckSeedPhraseCubitState> {
  final List<String> originalPhrase;
  final List<CheckSeedCorrectAnswer> _correctAnswers;
  final List<String> availableAnswers;

  /// Answers that user selected, if empty then user haven't selected it yet
  final List<CheckSeedCorrectAnswer> userAnswers;

  /// Navigate to other screen
  final VoidCallback completeChecking;

  /// if null - all words selected
  int? currentCheckIndex = 0;

  factory CheckSeedPhraseCubit(List<String> originalPhrase, VoidCallback completeChecking) {
    final correct = _selectCorrectAnswers(originalPhrase);

    return CheckSeedPhraseCubit._(
      originalPhrase,
      completeChecking,
      correct,
      _generateAnswerWords(correct),
      correct.map((e) => e.copyWith(word: '')).toList(),
    );
  }

  CheckSeedPhraseCubit._(
    this.originalPhrase,
    this.completeChecking,
    this._correctAnswers,
    this.availableAnswers,
    this.userAnswers,
  ) : super(CheckSeedPhraseCubitState.answer(availableAnswers, userAnswers, 0));

  void answerQuestion(String answer) {
    if (state is _Correct) return;
    final index = currentCheckIndex;
    if (index == null) return;
    userAnswers[index] = userAnswers[index].copyWith(word: answer);
    _goNextOrValidate();
  }

  void clearAnswer(String answer) {
    if (state is _Correct) return;
    final answerIndex = userAnswers.indexWhere((a) => a.word == answer);
    userAnswers[answerIndex] = userAnswers[answerIndex].copyWith(word: '');
    _goNextOrValidate();
  }

  void _goNextOrValidate() {
    final nextIndex = _firstEmptyAnswer();
    if (nextIndex == null) {
      _validate();
    } else {
      _goNext(nextIndex);
    }
  }

  void _validate() {
    bool hasError = false;
    _correctAnswers.forEachIndexed(
      (index, answer) => hasError = answer.word != userAnswers[index].word || hasError,
    );
    if (hasError) {
      emit(CheckSeedPhraseCubitState.error(availableAnswers, userAnswers));
    } else {
      emit(CheckSeedPhraseCubitState.correct(availableAnswers, userAnswers));
      Future<void>.delayed(delayBeforeCompleteChecking, () {
        completeChecking();
      });
    }
  }

  void _goNext(int nextIndex) {
    currentCheckIndex = nextIndex;
    emit(CheckSeedPhraseCubitState.answer(availableAnswers, List.of(userAnswers), nextIndex));
  }

  int? _firstEmptyAnswer() {
    for (int i = 0; i < userAnswers.length; i++) {
      if (userAnswers[i].word.isEmpty) return i;
    }
    return null;
  }

  /// Correct answers for internal checks
  static List<CheckSeedCorrectAnswer> _selectCorrectAnswers(List<String> phrase) {
    final rng = Random();
    final indices = <int>[];

    while (indices.length < kDefaultWordsToCheckAmount) {
      final number = rng.nextInt(phrase.length);

      if (indices.contains(number)) {
        continue;
      }

      indices.add(number);
    }

    indices.sort();

    return [for (final index in indices) CheckSeedCorrectAnswer(phrase[index], index)];
  }

  /// List of words that users choose of
  static List<String> _generateAnswerWords(List<CheckSeedCorrectAnswer> correct) {
    final correctWords = correct.map((e) => e.word).toList();
    final dictionary = getHints('');
    final answers = <String>[...correctWords];
    final random = Random();
    while (answers.length < kDefaultCheckAnswersAmount) {
      final number = random.nextInt(dictionary.length);
      if (answers.contains(dictionary[number])) {
        continue;
      }
      answers.add(dictionary[number]);
    }
    // to be sure it was shuffled
    answers
      ..shuffle()
      ..shuffle()
      ..shuffle();
    return answers;
  }
}

@freezed
class CheckSeedPhraseCubitState with _$CheckSeedPhraseCubitState {
  /// Display answer without any selections
  const factory CheckSeedPhraseCubitState.answer(
    List<String> availableAnswers,
    List<CheckSeedCorrectAnswer> userAnswers,
    int currentAnswerIndex,
  ) = _Answer;

  /// Correct selection. Other selections must be blocked.
  /// Question will change automatically
  const factory CheckSeedPhraseCubitState.correct(
    List<String> availableAnswers,
    List<CheckSeedCorrectAnswer> userAnswers,
  ) = _Correct;

  /// Error selection
  const factory CheckSeedPhraseCubitState.error(
    List<String> availableAnswers,
    List<CheckSeedCorrectAnswer> userAnswers,
  ) = _Error;
}

class CheckSeedCorrectAnswer {
  /// If word is empty string then user doesn't answered
  final String word;

  /// Starts with 0
  final int wordIndex;

  CheckSeedCorrectAnswer(this.word, this.wordIndex);

  CheckSeedCorrectAnswer copyWith({required String word}) =>
      CheckSeedCorrectAnswer(word, wordIndex);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckSeedCorrectAnswer &&
          runtimeType == other.runtimeType &&
          word == other.word &&
          wordIndex == other.wordIndex;

  @override
  int get hashCode => word.hashCode ^ wordIndex.hashCode;

  @override
  String toString() {
    return 'CheckSeedCorrectAnswer{word: $word, wordIndex: $wordIndex}';
  }
}
