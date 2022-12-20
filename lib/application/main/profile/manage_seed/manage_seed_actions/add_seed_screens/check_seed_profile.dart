import 'package:ever_wallet/application/adding_seed_to_app/check_seed_phrase/check_seed_phrase_widget.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/add_seed_screens/create_password_profile.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:flutter/material.dart';

class CheckSeedProfileRoute extends MaterialPageRoute<void> {
  CheckSeedProfileRoute(List<String> phrase, [String? name])
      : super(builder: (_) => CheckSeedProfileScreen(phrase: phrase, name: name));
}

class CheckSeedProfileScreen extends StatelessWidget {
  const CheckSeedProfileScreen({
    super.key,
    required this.phrase,
    required this.name,
  });

  final List<String> phrase;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: CheckSeedPhraseWidget(
        phrase: phrase,
        navigateToPassword: (context) {
          Navigator.of(context).push(CreatePasswordProfileRoute(phrase, name));
        },
        primaryColor: ColorsRes.bluePrimary400,
        defaultTextColor: ColorsRes.black,
        errorColor: ColorsRes.red400Primary,
        defaultBorderColor: ColorsRes.neutral750,
        secondaryTextColor: ColorsRes.neutral400,
        availableAnswersTextColor: ColorsRes.bluePrimary400,
        notSelectedTextColor: ColorsRes.neutral600,
      ),
    );
  }
}
