import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConfirmsTitle extends StatelessWidget {
  final int signsReceived;
  final int signsRequired;

  const ConfirmsTitle({
    super.key,
    required this.signsReceived,
    required this.signsRequired,
  });

  @override
  Widget build(BuildContext context) => Text(
        AppLocalizations.of(context)!.signed_n_of_k('$signsReceived', '$signsRequired'),
        style: const TextStyle(
          color: Colors.black45,
        ),
      );
}
