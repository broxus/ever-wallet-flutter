import 'package:ever_wallet/application/adding_seed_to_app/create_password/create_seed_password_widget.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:flutter/material.dart';

class CreatePasswordProfileRoute extends MaterialPageRoute<void> {
  CreatePasswordProfileRoute(List<String> phrase, [String? name])
      : super(builder: (_) => CreatePasswordProfileScreen(phrase: phrase, name: name));
}

class CreatePasswordProfileScreen extends StatelessWidget {
  const CreatePasswordProfileScreen({
    required this.phrase,
    required this.name,
    super.key,
  });

  final List<String> phrase;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: CreateSeedPasswordWidget(
        phrase: phrase,
        name: name,
        callback: (BuildContext context) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        setCurrentKey: false,
        primaryColor: ColorsRes.bluePrimary400,
        defaultTextColor: ColorsRes.black,
        secondaryTextColor: ColorsRes.neutral400,
        buttonTextColor: ColorsRes.white,
        errorColor: ColorsRes.red400Primary,
        needBiometryIfPossible: false,
      ),
    );
  }
}
