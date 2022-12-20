import 'package:ever_wallet/application/adding_seed_to_app/enter_seed_phrase/enter_seed_phrase_widget.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/add_seed_screens/create_password_profile.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:flutter/material.dart';

class EnterSeedProfileRoute extends MaterialPageRoute<void> {
  EnterSeedProfileRoute(String? name) : super(builder: (_) => EnterSeedProfileScreen(name: name));
}

class EnterSeedProfileScreen extends StatelessWidget {
  const EnterSeedProfileScreen({super.key, required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: EnterSeedPhraseWidget(
        callback: (BuildContext context, List<String> phrase) {
          Navigator.of(context).push(CreatePasswordProfileRoute(phrase, name));
        },
        errorColor: ColorsRes.red400Primary,
        inactiveBorderColor: ColorsRes.neutral750,
        secondaryTextColor: ColorsRes.neutral700,
        primaryColor: ColorsRes.bluePrimary400,
        defaultTextColor: ColorsRes.black,
        buttonTextColor: ColorsRes.white,
      ),
    );
  }
}
