import 'package:flutter/material.dart';

import '../../util/extensions.dart';
import '../../util/theme_styles.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).extension<ThemeStyle>();

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(context.localization.welcome_title),
          const SizedBox(height: 16),
          Text(context.localization.welcome_subtitle),
        ],
      ),
    );
  }
}
