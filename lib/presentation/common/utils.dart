import 'dart:math';

import 'constants.dart';

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

String decentralizationPolicyLink() => 'https://broxus.com/';

String accountExplorerLink(String address) => 'https://tonscan.io/accounts/$address';

String transactionExplorerLink(String id) => 'https://tonscan.io/transactions/$id';
