import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:flutter/material.dart';

class CrystalSubtitle extends StatelessWidget {
  final String text;

  const CrystalSubtitle({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: TextAlign.start,
        style: StylesRes.regular16.copyWith(color: ColorsRes.black),
      );
}
