import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

Future<Tuple3<String, String?, String?>> parseScanResult(String value) async {
  String? address;
  String? amount;
  String? comment;

  final addressRegExp = RegExp(
    r'([\-]?[\d]:[\d\w\+\-\/]{64})|([\d\w\+\-\/]{48})|([13]{1}[a-km-zA-HJ-NP-Z1-9]{26,33}|bc1[a-z0-9]{39,59})|(0x[a-fA-F0-9]{40})',
  );

  final addressMatch = addressRegExp.stringMatch(value);

  if (addressMatch != null) {
    address = addressMatch;
  } else {
    throw InvalidAddressException();
  }

  final amountRegExp = RegExp(
    r'amount=[+-]?((\d+(\.\d*)?)|(\.\d+))',
  );

  final amountMatch = amountRegExp.firstMatch(value)?.group(1);

  if (amountMatch != null) {
    amount = amountMatch;
  }

  final commentRegExp = RegExp(
    r'comment=(.+?(?=&|$))',
  );

  final commentMatch = commentRegExp.firstMatch(value)?.group(1);

  if (commentMatch != null) {
    comment = Uri.decodeFull(commentMatch);
  }

  return Tuple3(address, amount, comment);
}
