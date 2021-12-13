import 'dart:math';

import 'phrase_generation.dart';

Map<int, String> generateCheckingMap(List<String> phrase) {
  final rng = Random();
  final indices = <int>[];

  while (indices.length < kDefaultCheckingWordsAmount) {
    final number = rng.nextInt(phrase.length);

    if (indices.contains(number)) {
      continue;
    }

    indices.add(number);
  }

  indices.sort();

  final map = {for (final index in indices) index: phrase[index]};

  return map;
}
