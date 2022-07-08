import 'dart:math' as math;

import 'package:hex/hex.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class LedgerSource {
  //TODO: Implement
  Future<String> getPublicKey(int accountId) async =>
      HEX.encode(List.generate(32, (index) => math.Random().nextInt(100)).toList());

  //TODO: Implement
  Future<String> sign({
    required int account,
    required List<int> message,
    LedgerSignatureContext? context,
  }) async =>
      HEX.encode(List.generate(64, (index) => math.Random().nextInt(100)).toList());
}
