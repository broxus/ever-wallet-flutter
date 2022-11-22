import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/widgets/transport_type_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FeesTitle extends StatelessWidget {
  final String fees;

  const FeesTitle({
    super.key,
    required this.fees,
  });

  @override
  Widget build(BuildContext context) => TransportTypeBuilderWidget(
        builder: (context, isEver) {
          final ticker = isEver ? kEverTicker : kVenomTicker;

          return Text(
            AppLocalizations.of(context)!.fees_a_t(fees, ticker),
            style: const TextStyle(
              color: Colors.black45,
            ),
          );
        },
      );
}
