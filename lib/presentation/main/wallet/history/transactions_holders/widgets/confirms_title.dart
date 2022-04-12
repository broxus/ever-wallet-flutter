import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../generated/codegen_loader.g.dart';

class ConfirmsTitle extends StatelessWidget {
  final int signsReceived;
  final int signsRequired;

  const ConfirmsTitle({
    Key? key,
    required this.signsReceived,
    required this.signsRequired,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Text(
        LocaleKeys.signed_n_of_k.tr(args: ['$signsReceived', '$signsRequired']),
        style: const TextStyle(
          color: Colors.black45,
        ),
      );
}
