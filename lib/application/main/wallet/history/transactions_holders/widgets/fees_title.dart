import 'package:ever_wallet/application/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FeesTitle extends StatelessWidget {
  final String fees;

  const FeesTitle({
    super.key,
    required this.fees,
  });

  @override
  Widget build(BuildContext context) => Text(
        AppLocalizations.of(context)!.fees_a_t(fees, kEverTicker),
        style: const TextStyle(
          color: Colors.black45,
        ),
      );
}
