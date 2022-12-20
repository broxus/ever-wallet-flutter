import 'package:ever_wallet/application/adding_seed_to_app/enter_seed_name/enter_seed_name.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:flutter/material.dart';

class EnterSeedNameProfileRoute extends MaterialPageRoute<void> {
  EnterSeedNameProfileRoute(EnterSeedNameNavigationCallback callback)
      : super(builder: (_) => EnterSeedNameProfileScreen(callback: callback));
}

class EnterSeedNameProfileScreen extends StatelessWidget {
  const EnterSeedNameProfileScreen({super.key, required this.callback});

  final EnterSeedNameNavigationCallback callback;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorsRes.white,
      child: EnterSeedNameWidget(
        callback: callback,
        buttonTextColor: ColorsRes.white,
        secondaryTextColor: ColorsRes.neutral400,
        defaultTextColor: ColorsRes.black,
        primaryColor: ColorsRes.bluePrimary400,
      ),
    );
  }
}
