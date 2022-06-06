import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../common/constants.dart';

class FeesTitle extends StatelessWidget {
  final String fees;

  const FeesTitle({
    Key? key,
    required this.fees,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Text(
        AppLocalizations.of(context)!.fees_a_t(fees, kEverTicker),
        style: const TextStyle(
          color: Colors.black45,
        ),
      );
}
