import 'package:ever_wallet/application/adding_seed_to_app/create_wallet/create_seed_widget.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/add_seed_screens/check_seed_profile.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/add_seed_screens/create_password_profile.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:flutter/material.dart';

class CreateSeedProfileRoute extends MaterialPageRoute<void> {
  CreateSeedProfileRoute(String? name) : super(builder: (_) => CreateSeedProfileScreen(name: name));
}

/// !!! Here displays only 12 words
class CreateSeedProfileScreen extends StatelessWidget {
  const CreateSeedProfileScreen({super.key, required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: CreateSeedWidget(
        checkCallback: (BuildContext context, List<String> phrase) {
          Navigator.of(context).push(CheckSeedProfileRoute(phrase, name));
        },
        skipCallback: (BuildContext context, List<String> phrase) {
          Navigator.of(context).push(CreatePasswordProfileRoute(phrase, name));
        },
        phraseBackgroundColor: ColorsRes.blue970,
        defaultTextColor: ColorsRes.black,
        primaryColor: ColorsRes.bluePrimary400,
        secondaryTextColor: ColorsRes.neutral400,
        checkButtonTextColor: ColorsRes.white,
        skipButtonColor: ColorsRes.white,
        needSkipButtonBorder: true,
      ),
    );
  }
}
