import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../generated/codegen_loader.g.dart';
import '../../../../../common/constants.dart';

class FeesTitle extends StatelessWidget {
  final String fees;

  const FeesTitle({
    Key? key,
    required this.fees,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Text(
        LocaleKeys.fees_a_t.tr(args: [fees, kEverTicker]),
        style: const TextStyle(
          color: Colors.black45,
        ),
      );
}
