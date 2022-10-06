import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../providers/common/network_type_provider.dart';
import '../../../../../common/constants.dart';

class FeesTitle extends StatelessWidget {
  final String fees;

  const FeesTitle({
    Key? key,
    required this.fees,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, child) {
          final ticker =
              ref.watch(networkTypeProvider).asData?.value == 'Ever' ? kEverTicker : kVenomTicker;

          return Text(
            AppLocalizations.of(context)!.fees_a_t(fees, ticker),
            style: const TextStyle(
              color: Colors.black45,
            ),
          );
        },
      );
}
