import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../generated/codegen_loader.g.dart';

class ExpireTitle extends StatelessWidget {
  final DateTime date;
  final bool expired;

  const ExpireTitle({
    Key? key,
    required this.date,
    required this.expired,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Text(
        LocaleKeys.n_at_k.tr(
          args: [
            if (expired) LocaleKeys.expired.tr() else LocaleKeys.expires.tr(),
            DateFormat('MMM d, H:mm').format(date)
          ],
        ),
        style: const TextStyle(
          color: Colors.black45,
        ),
      );
}
