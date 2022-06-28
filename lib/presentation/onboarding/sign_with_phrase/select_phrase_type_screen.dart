import 'package:flutter/material.dart';

class SelectPhraseTypeRute extends MaterialPageRoute<void> {
  SelectPhraseTypeRute() : super(builder: (_) => const SelectPhraseTypeScreen());
}

class SelectPhraseTypeScreen extends StatelessWidget {
  const SelectPhraseTypeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Navigator.of(context).push(EnterSeedPhraseRoute(24));
    return Container();
  }
}
