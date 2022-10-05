import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class ExpireTitle extends StatelessWidget {
  final DateTime date;
  final bool expired;

  const ExpireTitle({
    super.key,
    required this.date,
    required this.expired,
  });

  @override
  Widget build(BuildContext context) => Text(
        AppLocalizations.of(context)!.n_at_k(
          expired ? AppLocalizations.of(context)!.expired : AppLocalizations.of(context)!.expires,
          DateFormat('MMM d, H:mm').format(date),
        ),
        style: const TextStyle(
          color: Colors.black45,
        ),
      );
}
